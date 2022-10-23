
pub fn new_linear_scale(
    domain: (f64, f64),
    range: (f64, f64)
) -> impl Fn(f64) -> f64 {
    move |value: f64| {
        let min_domain = domain.0;
        let max_domain = domain.1;
        let min_range = range.0;
        let max_range = range.1;
        return (max_range - min_range) * (value - min_domain) / (max_domain - min_domain) + min_range
    }
}
