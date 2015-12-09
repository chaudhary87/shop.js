Promise = require 'broken'

emailRe = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

model.export =
  isRequired: (value)->
    return value if value && value != ''

    throw new Error 'Required'

  isEmail: (value)->
    return value.toLowerCase() if emailRe.test value

    throw new Error 'Enter a valid email'

  splitName: (value)->
    i = value.indexOf ' '
    @set 'user.firstName', value.slice 0, i
    @set 'user.lastName', value.slice i+1
    return value

  requiresStripe: (value)->
    throw new Error "Required" if @('type') == 'stripe' && (!value? || value == '')
    return value

  requireTerms: (value)->
    if !value
      throw new Error 'Please read and agree to the terms and conditions.'
    return value

  cardNumber: (value)->
    if @('type') != 'stripe'
      return value

    return new Promise (resolve, reject)->
      requestAnimationFrame ()->
        if $('input[name=number]').hasClass('jp-card-invalid')
          reject new Error('Enter a valid card number')
        resolve value

  expiration: (value)->
    if @('type') != 'stripe'
      return value

    date = value.split '/'
    if date.length < 2
      throw new Error('Enter a valid expiration date')

    @set('payment.account.month', (date[0]).trim?())
    @set('payment.account.year', ('' + (new Date()).getFullYear()).substr(0, 2) + (date[1]).trim?())

    return new Promise (resolve, reject)->
      requestAnimationFrame ()->
        if $('input[name=expiry]').hasClass('jp-card-invalid')
          reject new Error('Enter a valid expiration date')
        resolve value

  cvc: (value)->
    if @('type') != 'stripe'
      return value

    return new Promise (resolve, reject)->
      requestAnimationFrame ()->
        if $('input[name=cvc]').hasClass('jp-card-invalid')
          reject new Error('Enter a valid CVC number')
        resolve value
