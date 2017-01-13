Template.adminBackupRestore.helpers
	isAdmin: ->
		return RocketChat.authz.hasRole(Meteor.userId(), 'admin')

	uploading: ->
		Template.instance().uploading.get()

	restoring: ->
		Template.instance().restoring.get()

	restoreInProgress: ->
		return Template.instance().uploading.get() && Session.get('restoreInProgress')

	downloadToken : ->
		if Meteor.user()
			return Accounts?._storedLoginToken()

Template.adminBackupRestore.onCreated ->
	@uploading = new ReactiveVar false
	@restoring = new ReactiveVar false

Template.adminBackupRestore.events
	'change #restore': (event, template) ->
		templateRef = template
		subsManager = new SubsManager
		swal
			title: t('Restore_Confirm')
			showCancelButton: true
			closeOnConfirm: true
			closeOnCancel: true
			type: 'warning'
			html: true
			, (isConfirm) ->
				if isConfirm
					record =
						name: $('#restore')[0].files[0].name
						size: $('#restore')[0].files[0].size
						type: $('#restore')[0].files[0].type

					upload = new FileUpload.Restore(record, $('#restore')[0].files[0])
					upload.onProgress = (progress) ->
						templateRef.uploading.set progress > 0
					upload.onError = (error) ->
						swal
							title: t('Error')
							text: t('Cannot_complete')
							type: 'error'
					upload.onFinish = (fileData) ->
						templateRef.restoring.set true
						Meteor.call 'restoreBackup', [
							fileData,
							->
								swal
									title: t('Completed')
									text: t('Backup_restored')
									type: 'success'
						]
						Meteor.logout ->
							subsManager.clear

					upload.start()
				else
					$('#restore').val('')
