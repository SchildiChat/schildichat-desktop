const fs = require('fs');
const path = require('path');
const globby = require('globby');

function readStrings(p) {
	return JSON.parse(fs.readFileSync(p).toString());
}

function writeStrings(p, strings) {
	fs.writeFileSync(p, JSON.stringify(strings, null, 4) + "\n");
}

(async () => {
	console.log(process.argv.length);
	console.log(process.argv[0]);
	console.log(process.argv[1]);
	console.log(process.argv[2]);
	console.log(process.argv[3]);
	if (process.argv.length < 3) {
		console.log("No path with the original strings given!");
		process.exit(-1);
	}
	originalPath = process.argv[2];

	overlayPath = null;
	if (process.argv.length > 3) {
		overlayPath = process.argv[3];
	} else {
		console.log("Continue without overlays ...")
	}

	const paths = await globby(path.join(originalPath, "*.json"));

	paths.forEach(p => {
		let strings = readStrings(p);

		for (const key of Object.keys(strings)) {
			strings[key] = strings[key]
				.replace(/Element/g, "SchildiChat")
				.replace(/element\.io/g, "schildi.chat")
				
				// It's still Element Call
				.replace(/SchildiChat Call/g, "Element Call")
				.replace(/SchildiChat-Call/g, "Element-Call");
		}

		if (overlayPath) {
			op = path.join(overlayPath, path.basename(p)); 
			
			if (fs.existsSync(op)) {
				overlayStrings = readStrings(op);
				Object.assign(strings, overlayStrings);
			}
		}

		writeStrings(p, strings);
	});
})();