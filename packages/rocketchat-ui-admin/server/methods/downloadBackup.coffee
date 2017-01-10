import { Mongo } from 'meteor/mongo'

Meteor.methods
	'downloadBackup': ->
		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'downloadBackup' }
		#console.log(RocketChat.models.Users.find({}).fetch())
		backupContent = ''
		console.log RocketChat.models
		for model in RocketChat.models
			backupContent += JSON.stringify(model.find({}).fetch())
		console.log backupContent
