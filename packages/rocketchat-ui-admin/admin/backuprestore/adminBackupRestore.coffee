Template.adminBackupRestore.helpers
	isAdmin: ->
		return RocketChat.authz.hasRole(Meteor.userId(), 'admin')

Template.adminBackupRestore.events
  'click .download-backup': (event) ->
    Meteor.call('downloadBackup')
