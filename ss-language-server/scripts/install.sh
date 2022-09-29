set -e

cd vscode-subscript-markup-language
npm run build
cd ..

mkdir -p ~/.vscode/extensions/vscode-subscript-markup-language
mkdir -p ~/.vscode/extensions/vscode-subscript-autocomplete

rm -rf ~/.vscode/extensions/vscode-subscript-markup-language
rm -rf ~/.vscode/extensions/vscode-subscript-autocomplete

cp -r vscode-subscript-markup-language ~/.vscode/extensions/
cp -r vscode-subscript-autocomplete ~/.vscode/extensions/

