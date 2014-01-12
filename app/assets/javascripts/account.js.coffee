$ ->
    accountUri = '/accounts'

    $("#cc-submit").click (e) ->
      e.preventDefault()
      amount = $("#deposit-amount").val()
      payload =
        name: $("#cc-name").val()
        card_number: $("#cc-number").val()
        expiration_month: $("#cc-ex-month").val()
        expiration_year: $("#cc-ex-year").val()
        security_code: $("#ex-csc").val()
      
      # Tokenize credit card
      balanced.card.create payload, (response) ->

        if response.status is 201 and response.data
          $.post accountUri,
            amount: amount
            account:
              ext_account_id: response.data.uri
          , (r) ->
            
            if r.status is 201
              alert "Account created."
            else
              alert "Error: "+JSON.stringify(response.error, false, 4)

        else
          alert "Error: "+JSON.stringify(response.error, false, 4)
  
    $("#ba-submit").click (e) ->
      e.preventDefault()
      $("#response").hide()
      payload =
        name: $("#ba-name").val()
        account_number: $("#ba-number").val()
        routing_number: $("#ba-routing").val()
      
      # Tokenize bank account
      balanced.bankAccount.create payload, (response) ->
        
        if response.status is 201 and response.href
          
          jQuery.post responseTarget,
            uri: response.href
          , (r) ->
            
            if r.status is 201
            
            else

        else
  
  
    #//
    # Simply populates credit card and bank account fields with test data
    #//
    $("#populate").click ->
      $(this).attr "disabled", true
      $("#cc-number").val "4111111111111111"
      $("#cc-ex-month").val "12"
      $("#cc-ex-year").val "2020"
      $("#ex-csc").val "123"
      $("#ba-name").val "John Hancock"
      $("#ba-number").val "9900000000"
      $("#ba-routing").val "321174851"

