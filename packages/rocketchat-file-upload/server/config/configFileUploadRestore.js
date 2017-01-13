/* globals RestoreFileSystemStore:true, FileUpload, UploadFS, RocketChatFile */

let storeName = 'RestoreFileSystemStore';
const os = require('os');

RestoreFileSystemStore = null;

let createFileSystemStore = _.debounce(function() {
	let stores = UploadFS.getStores();
	if (stores[storeName]) {
		delete stores[storeName];
	}
	RestoreFileSystemStore = new UploadFS.store.Local({
		collection: RocketChat.models.Uploads.model,
		name: storeName,
		path: os.tmpdir(),
		filter: new UploadFS.Filter({
			onCheck: function (file) { return /^application\/x-tar$/.test(file.type); }
		}),
	});
}, 500);

RocketChat.settings.get('FileUpload_FileSystemPath', createFileSystemStore);

let fs = Npm.require('fs');

FileUpload.addHandler(storeName, {
	get(file, req, res) {
		let filePath = RestoreFileSystemStore.getFilePath(file._id, file);

		try {
			let stat = Meteor.wrapAsync(fs.stat)(filePath);

			if (stat && stat.isFile()) {
				file = FileUpload.addExtensionTo(file);
				res.setHeader('Content-Disposition', `attachment; filename*=UTF-8''${encodeURIComponent(file.name)}`);
				res.setHeader('Last-Modified', file.uploadedAt.toUTCString());
				res.setHeader('Content-Type', file.type);
				res.setHeader('Content-Length', file.size);

				FileSystemStore.getReadStream(file._id, file).pipe(res);
			}
		} catch (e) {
			res.writeHead(404);
			res.end();
			return;
		}
	},
	delete(file) {
		return FileSystemStore.delete(file._id);
	}
});
