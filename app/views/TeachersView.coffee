AuthModal = require 'views/core/AuthModal'
RootView = require 'views/core/RootView'
template = require 'templates/teachers'

module.exports = class TeachersView extends RootView
  id: 'teachers-view'
  template: template

  events:
    'click .btn-create-account': 'onClickSignup'
    'click .btn-login-account': 'onClickLogin'
    'click .link-register': 'onClickSignup'

  constructor: ->
    super()
    unless me.isAnonymous()
      _.defer ->
        application.router.navigate "/courses/teachers", trigger: true

  onClickLogin: (e) ->
    @openModalView new AuthModal(mode: 'login') if me.get('anonymous')
    window.tracker?.trackEvent 'Started Signup', category: 'Teachers', label: 'Teachers Login'

  onClickSignup: (e) ->
    @openModalView new AuthModal() if me.get('anonymous')
    window.tracker?.trackEvent 'Started Signup', category: 'Teachers', label: 'Teachers Create'

  logoutRedirectURL: false
