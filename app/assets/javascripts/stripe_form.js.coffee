window.initializeStripeForm = ->
  initTestHelpers()
  stripeForm = new StripeForm()
  stripeForm.init initCallback

# Generic form for handling credit cards, bank accounts, etc
class StripeForm

  constructor: ->
    Stripe.setPublishableKey $('meta[name="stripe-key"]').attr('content')
    @form = $('[data-stripe-action]')
    throw 'There must be a form with a data-stripe-action attribute!' unless @form.length > 0
    @stripeAction = @form.data('stripe-action')

  showFormErrors: (errors) ->
    for key of errors
      input = @form.find("[data-payload='#{key}']")
      input.after('<div class="error">' + errors[key] + '</div>')

  isValid: (payload) ->
    valid = true
    errors = {}
    if @stripeAction == 'card'
      unless Stripe.card.validateCardNumber(payload.number)
        errors['number'] = 'Is not a valid card number'
        valid = false
      unless Stripe.card.validateExpiry(payload.exp_month, payload.exp_year)
        errors['exp_year'] = 'Is not a valid expiry date'
        valid = false
      unless Stripe.card.validateCVC(payload.cvc)
        errors['cvc'] = 'Is not a valid cvc number'
        valid = false

    @showFormErrors(errors) unless valid
    valid

  init: (onSuccess) ->
    $('#stripeSubmit').click (e) =>
      e.preventDefault()
      @clearErrors()
      payload = @getPayload()
      return unless @isValid(payload)
      Stripe[@stripeAction].createToken payload, (status, response) =>
        return @displayError(status, response) if status isnt 200
        onSuccess(@stripeAction, response)

  clearErrors: ->
    @form.find('.error-container').hide()
    @form.find('.error').remove()

  displayError: (status, response) ->
    $('.error-container')
      .show()
      .append('<span class="error">' + response.error.message + '</span>')

  # Get the payload values.
  getPayload: ->
    payload = {}
    @form.find('[data-payload]').each ->
      self = $(@)
      payload[self.data('payload')] = self.val()
    payload

initCallback = (action, response) ->
  url = ''
  if action is 'card'
    url = 'credit_cards'
    data =
      stripe_token: response.id
      amount: $('#depositAmount').val()
      credit_card:
        stripe_id: response.card.id
        card_brand: response.card.type
        last_four: response.card.last4
  else if action is 'bankAccount'
    url = 'create_bank'
    data =
      stripe_token: response.id
      bank_account:
        name: response.bank_account.bank_name
        stripe_id: response.bank_account.id
        last_four: response.bank_account.last4

  promise = $.post '/accounts/' + url, data

  promise.success ->
    window.location.reload()

  promise.error (res) ->
    $('.error-container')
      .show()
      .append('<span class="help-block">' + res.responseJSON.error + '>')

initTestHelpers = ->
  # Simply populates credit card and bank account fields with test data
  $("#populate").click ->
    data =
      number: '4242424242424242'
      cvc: '123'
      name:' John Hancock'
      exp_month: 12
      exp_year: 2020
      accountNumber: '000123456789'
      routingNumber: '110000000'
      address_state: 'NY'
      address_zip: '10007'

    for key of data
      $('[data-payload="' + key + '"]').val(data[key])

    $(this).attr 'disabled', true

