restore = Npm.require('mongodb-restore')
os = Npm.require('os')

Meteor.methods
	restoreBackup: (backupFile, callBack) ->
		restoreOptions =
			uri: process.env.MONGO_URL
			root: os.tmpdir()
			tar: backupFile[0]._id + '.tar'
			parser: 'bson'
			dropCollections: true
			callback : Meteor.bindEnvironment callBack
		syncRestore = Meteor.wrapAsync(restore)
		syncRestore(restoreOptions)
