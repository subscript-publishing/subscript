
#[derive(Debug, Clone)]
pub enum Op<T> {
    Insert(T),
    Delete(T),
}

