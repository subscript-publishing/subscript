let root = document.documentElement;

function updateColumns() {
    const force_single_column = localStorage.getItem('preference.force-single-column');
    const wrapper = document.getElementById('site-settings-wrapper');
    const selector = "main [data-col], main section, main h1, main h2, main h3, main h4, main h5, main h6";
    if (force_single_column != null) {
        console.log("force_single_column", force_single_column);
        if (force_single_column == "1") {
            wrapper.setAttribute("force-single-col", 'on');
            document.querySelectorAll(selector).forEach((node) => {
                node.setAttribute("force-single-col", 'on');
            });
        }
        if (force_single_column == "0") {
            wrapper.setAttribute("force-single-col", 'off');
            document.querySelectorAll(selector).forEach((node) => {
                node.setAttribute("force-single-col", 'off');
            });
        }
    } else {
        wrapper.setAttribute("force-single-col", 'off');
    }
}

window.addEventListener('load', () => {
    updateColumns();
});

function setForceSingleColumnToOff() {
    console.log("set force single column to off");
    localStorage.setItem('preference.force-single-column', '0');
    updateColumns();
}

function setForceSingleColumnToOn() {
    console.log("set force single column to on");
    localStorage.setItem('preference.force-single-column', '1');
    updateColumns();
}

