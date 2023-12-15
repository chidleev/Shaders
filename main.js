async function init() {
    let options = {
        fragmentString: ``,
        antialias: true,
        mode: 'flat',
        qualityFactor: 1
    };

    let response = await fetch("./fragment.glsl");
    if (response.ok) {
        options.fragmentString = await response.text();
    } else {
        alert("Ошибка HTTP: " + response.status);
    }

    let canvas1 = document.getElementById("canvas1");
    const glslCanvas1 = new glsl.Canvas(canvas1, options);
}

init();