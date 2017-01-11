Template.adminBackupRestore.helpers
	isAdmin: ->
		return RocketChat.authz.hasRole(Meteor.userId(), 'admin')

	dumpUiData: ->
		return {advanced: true}
Template.adminBackupRestore.events
  'click .download-backup': (event) ->
		Meteor.call 'downloadBackup', '', (error, result) ->
			console.log result

if Meteor.isServer
	Router.onBeforeAction IR_Filters.mustBeSignedIn,
		except: ['appDumpHTTP']
	appDump.allow = ->
		return true
