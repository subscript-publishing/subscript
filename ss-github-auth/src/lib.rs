// use dialoguer::{Input, PasswordInput};
// use directories::ProjectDirs;
use serde::{Serialize, Deserialize};
use surf::http::{bail, headers};
use surf::Body;
use std::io::prelude::*;
use std::path::PathBuf;

/// The GitHub authorization base URL
pub const GITHUB_AUTH_URL: &str = "https://api.github.com/authorizations";

#[derive(Debug, Serialize, Deserialize)]
struct AuthResponse {
    // username: String,
    pub token: String,
}

/// A GitHub auth instance.
#[derive(Debug)]
pub struct Authenticator {
    config: Builder,
}

/// An authentication request for GitHub
#[derive(Debug, Serialize)]
struct AuthRequest {
    note: String,
    scopes: Option<Vec<Scope>>,
}

impl AuthRequest {
    /// Create a new instance.
    pub fn new(note: String, scopes: Option<Vec<Scope>>) -> Self {
        Self { note, scopes }
    }
}

impl Authenticator {
    /// Create a new instance with no scopes allowed.
    pub fn new() -> Self {
        Builder::new().build()
    }

    /// Create a new instance and configure it.
    pub fn builder() -> Builder {
        Builder::new()
    }

    /// Get the location at which the token is stored.
    pub fn token_file_path(&self) -> PathBuf {
        let user_dirs = directories_next::UserDirs::new().unwrap();
        let mut token_path = user_dirs.document_dir().unwrap().to_path_buf();
        token_path.push("github-auth-token.json");
        token_path
    }

    /// Remove the token from the local storage.
    pub fn delete(&self) {
        // std::fs::remove_file(self.token_file_path()).unwrap();
        unimplemented!("TODO");
    }

    /// Authenticate with GitHub.
    pub async fn auth(
        &self,
        username: impl AsRef<str>,
        password: impl AsRef<str>,
        token_override_path: Option<PathBuf>,
        // otp: Option<T>,
    ) -> surf::Result<Token> {
        let token_file_path = {
            token_override_path.unwrap_or_else(|| self.token_file_path())
        };
        if token_file_path.exists() {
            let token_file_contents = std::fs::read(&token_file_path).unwrap();
            let token = serde_json::from_slice::<AuthResponse>(&token_file_contents).unwrap();
            return Ok(Token::new(token.token));
        }

        // Create HTTP body
        let note = self.config.note.clone();
        let scopes = self.config.scopes.clone();
        let body = AuthRequest::new(note, scopes);

        // Encode username / password for basic auth.
        let mut auth_value = b"Basic ".to_vec();
        let mut encoder = base64::write::EncoderWriter::new(&mut auth_value, base64::STANDARD);
        write!(encoder, "{}:{}", username.as_ref(), password.as_ref())?;
        drop(encoder);
        let auth_value = String::from_utf8(auth_value)?;

        // Perform HTTP request.
        let mut res = surf::post(GITHUB_AUTH_URL)
            // .header("X-GitHub-OTP", otp)
            .header("User-Agent", "github_auth")
            .header(headers::AUTHORIZATION, auth_value)
            .body(Body::from_json(&body)?)
            .await?;

        // Parse request output.
        let status = res.status();
        if !status.is_success() {
            bail!(
                "{:?} {:?}",
                res.body_string().await?,
                status.canonical_reason()
            );
        };
        let json: AuthResponse = res.body_json().await?;
        let serialized = serde_json::to_vec(&json).unwrap();
        std::fs::write(&token_file_path, serialized).unwrap();
        Ok(Token::new(json.token))
    }
}

impl Default for Authenticator {
    /// Create a new instance of
    fn default() -> Self {
        Builder::new()
            .note("A token created with the github_auth Rust crate.".into())
            .build()
    }
}


/// Create a new [`Authenticator`] instance.
#[derive(Debug, Default)]
pub struct Builder {
    scopes: Option<Vec<Scope>>,
    note: String,
}

impl Builder {
    /// Create a new instance.
    pub fn new() -> Self {
        Default::default()
    }

    /// Set a custom note for the token stored on GitHub. Defaults to mentioning
    /// the token name.
    pub fn note(mut self, note: String) -> Self {
        self.note = note;
        self
    }

    /// Add a scope. [Read more.](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)
    pub fn scope(mut self, scope: Scope) -> Self {
        if self.scopes.is_none() {
            self.scopes = Some(Default::default());
        }
        self.scopes.as_mut().unwrap().push(scope);
        self
    }

    /// Finalize the builder, and return an `Authenticator` instance.
    pub fn build(self) -> Authenticator {
        Authenticator { config: self }
    }
}


/// Token returned by the authenticator function.
#[derive(Debug, PartialEq)]
pub struct Token(String);

impl Token {
    fn new(bytes: String) -> Self {
        Token(bytes)
    }

    /// Convert to a string.
    pub fn into_string(self) -> String {
        self.0
    }
}

impl std::fmt::Display for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}


/// GitHub OAuth scope definitions.
///
/// ## Further Reading
/// - [Understanding scopes for Oauth apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Scope {
    /// Grants read/write access to code, commit statuses, invitations,
    /// collaborators, adding team memberships, and deployment statuses for public
    /// and private repositories and organizations.
    #[serde(rename = "repo")]
    Repo,
    /// Grants read/write access to public and private repository commit statuses.
    /// This scope is only necessary to grant other users or services access to
    /// private repository commit statuses without granting access to the code.
    #[serde(rename = "repo:status")]
    RepoStatus,
    /// Grants access to deployment statuses for public and private repositories.
    /// This scope is only necessary to grant other users or services access to
    /// deployment statuses, without granting access to the code.
    #[serde(rename = "repo_deployment")]
    RepoDeployment,
    /// Grants read/write access to code, commit statuses, collaborators, and
    /// deployment statuses for public repositories and organizations. Also
    /// required for starring public repositories.
    #[serde(rename = "public_repo")]
    PublicRepo,
    /// Grants accept/decline abilities for invitations to collaborate on a
    /// repository. This scope is only necessary to grant other users or services
    /// access to invites without granting access to the code.
    #[serde(rename = "repo:invite")]
    RepoInvite,
    /// Fully manage organization, teams, and memberships.
    #[serde(rename = "admin:org")]
    AdminOrg,
    /// Publicize and unpublicize organization membership.
    #[serde(rename = "write:org")]
    WriteOrg,
    /// Read-only access to organization, teams, and membership.
    #[serde(rename = "read:org")]
    ReadOrg,
    /// Fully manage public keys.
    #[serde(rename = "admin:public_key")]
    AdminPublicKey,
    /// Create, list, and view details for public keys.
    #[serde(rename = "write:public_key")]
    WritePublicKey,
    /// List and view details for public keys.
    #[serde(rename = "read:public_key")]
    ReadPublicKey,
    /// Grants read, write, ping, and delete access to hooks in public or private
    /// repositories.
    #[serde(rename = "admin:repo_hook")]
    AdminRepoHook,
    /// Grants read, write, and ping access to hooks in public or private repositories.
    #[serde(rename = "write:repo_hook")]
    WriteRepoHook,
    /// Grants read and ping access to hooks in public or private repositories.
    #[serde(rename = "read:repo_hook")]
    ReadRepoHook,
    /// Grants read, write, ping, and delete access to organization hooks. Note:
    /// OAuth tokens will only be able to perform these actions on organization
    /// hooks which were created by the OAuth App. Personal access tokens will
    /// only be able to perform these actions on organization hooks created by a
    /// user.
    #[serde(rename = "admin:org_hook")]
    AdminOrgHook,
    /// Grants write access to gists.
    #[serde(rename = "gist")]
    Gist,
    /// Grants read access to a user's notifications. repo also provides this
    /// access.
    #[serde(rename = "notifications")]
    Notifications,
    /// Grants read/write access to profile info only. Note that this scope
    /// includes `user:email` and `user:follow`.
    #[serde(rename = "user")]
    User,
    /// Grants access to read a user's profile data.
    #[serde(rename = "read:user")]
    ReadUser,
    /// Grants read access to a user's email addresses.
    #[serde(rename = "user:email")]
    UserEmail,
    /// Grants access to follow or unfollow other users.
    #[serde(rename = "user:follow")]
    UserFollow,
    /// Grants access to delete adminable repositories.
    #[serde(rename = "delete_repo")]
    DeleteRepo,
    /// Allows read and write access for team discussions.
    #[serde(rename = "write:discussion")]
    WriteDiscussion,
    /// Allows read access for team discussions.
    #[serde(rename = "read:discussion")]
    ReadDiscussion,
    /// Fully manage GPG keys.
    #[serde(rename = "admin:gpg_key")]
    AdminGpgKey,
    /// Create, list, and view details for GPG keys.
    #[serde(rename = "write:gpg_key")]
    WriteGpgKey,
    /// List and view details for GPG keys.
    #[serde(rename = "read:gpg_key")]
    ReadGpgKey,
}


pub fn load_or_init_new_token(
    username: impl AsRef<str>,
    password: impl AsRef<str>,
    token_override_path: Option<PathBuf>,
) -> Token {
    let auth = Authenticator::new();
    futures::executor::block_on(auth.auth(username, password, token_override_path)).unwrap()
}

