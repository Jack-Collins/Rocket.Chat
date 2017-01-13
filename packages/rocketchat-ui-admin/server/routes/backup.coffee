backup = Npm.require('mongodb-backup')
restore = Npm.require('mongodb-restore')
multiparty = Npm.require('multiparty')
moment = Npm.require('moment')
path = Npm.require('path')
fs = Npm.require('fs')

Router.map ->
	@route 'backup',
		path: '/admin/backup',
		where: 'server',
		action: ->
			self = @
			req = @request
			res = @response
			req.query.parser?= ''
			check req.query.parser, String
			self.options =
				parser: req.query.parser

			# parse the collections
			if req.query.collections
				check req.query.collections, String

				# convert commas into array
				self.options.collections = req.query.collections.split(',').map (col) -> col.trim()

				if self.options.collections.length is 0
					self.options.collections = null

			# parse the query
			if req.query.query
				check req.query.query, String
				try
					self.options.query = JSON.parse req.query.query
				catch e
					res.statusCode = 401
					res.end "Failed to parse JSON Query"
					return false


			# add the token
			token = req.query.token || ''
			check token, String
			self.user = Meteor.users.findOne({'roles': {'$in': ['admin']}, 'services.resume.loginTokens.hashedToken': Accounts._hashLoginToken(token)});
			if !self.user
				res.statusCode = 401
				res.end 'Unauthorized'
				return false

			meteor_root = fs.realpathSync(process.cwd() + '/../')
			application_root = fs.realpathSync(meteor_root + '/../')

			if path.basename(fs.realpathSync(meteor_root + '/../../../')) == '.meteor'
				application_root = fs.realpathSync(meteor_root + '/../../../../')

			separator = if application_root.indexOf('\\') > -1 then '\\' else '/'

			if req.query.filename
				check req.query.filename, String
				filename = req.query.filename.replace(/[^a-z0-9_-]/gi, '_') + '.tar'

			unless filename
				safe =
					host: req.headers.host.replace(/[^a-z0-9]/gi, '-').toLowerCase()
					app: application_root.split(separator).pop().replace(/[^a-z0-9]/gi, '-').toLowerCase()
					date: moment().format("YY-MM-DD_HH-mm-ss")
					parser: self.options.parser || 'bson'

				filename = "rocketchat_backup_#{safe.parser}_#{safe.app}_#{safe.host}_#{safe.date}.tar"
			res.statusCode = 200
			res.setHeader 'Content-disposition', "attachment; filename=#{filename}"

			backupOptions =
				uri: process.env.MONGO_URL
				stream: res
				tar: 'dump.tar'
				query: self.options.query
				parser: self.options.parser

			if self.options.collections
				backupOptions.collections = self.options.collections

			asyncBackup = Meteor.wrapAsync backup
			asyncBackup backupOptions
			res.end
