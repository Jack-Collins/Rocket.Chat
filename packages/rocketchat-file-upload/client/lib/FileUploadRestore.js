/* globals FileUploadBase, UploadFS, FileUpload:true, RocketChatFile, RestoreFileSystemStore:true */

RestoreFileSystemStore = new UploadFS.store.Local({
	collection: RocketChat.models.Uploads.model,
	name: 'RestoreFileSystemStore',
	filter: new UploadFS.Filter({
		onCheck: function (file) {return true;}
	})
});

FileUpload.Restore = class FileUploadRestore extends FileUploadBase {
	constructor(meta, file) {
		super(meta, file);
		let self = this;
		this.handler = new UploadFS.Uploader({
			store: RestoreFileSystemStore,
			data: file,
			file: meta,
			onError: (err) => {
				self.onError(err)
			},
			onComplete: (fileData) => {
				self.onFinish(fileData);
			},
		});
		this.handler.onProgress = (file, progress) => {
			this.onProgress(progress);
		};
	}

	start() {
		const uploading = Session.get('uploading') || [];
		const item = {
			id: this.id,
			name: this.getFileName(),
			percentage: 0
		};
		uploading.push(item);
		Session.set('uploading', uploading);
		return this.handler.start();
	}

	onProgress() {
	}

	onError(error) {

	}

	onFinish(fileData) {

	}

	stop() {
		return this.handler.stop();
	}
};
