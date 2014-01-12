class CreditCard

  constructor: ->
    marketplaceUri = "/v1/marketplaces/TEST-MPEO3uigheQUEL2WW6VnaCQ"
    balanced.init marketplaceUri
    
    #//
    # Click event for tokenize credit card
    #//
    $("#cc-submit").click (e) ->
      e.preventDefault()
      $("#response").hide()
      payload =
        card_number: $("#cc-number").val()
        expiration_month: $("#cc-ex-month").val()
        expiration_year: $("#cc-ex-year").val()
        security_code: $("#ex-csc").val()
      
      # Tokenize credit card
      balanced.card.create payload, (response) ->
        
        # Successful tokenization
        if response.status is 201 and response.href
          
        else
  
        
        # Failed to tokenize, your error logic here
        
  
    
    #//
    # Click event for tokenize bank account
    #//
    $("#ba-submit").click (e) ->
      e.preventDefault()
      $("#response").hide()
      payload =
        name: $("#ba-name").val()
        account_number: $("#ba-number").val()
        routing_number: $("#ba-routing").val()
  
      
      # Tokenize bank account
      balanced.bankAccount.create payload, (response) ->
        
        # Successful tokenization
        if response.status is 201 and response.href
          
          # Send to your backend
          jQuery.post responseTarget,
            uri: response.href
          , (r) ->
            
            # Check your backend response
            if r.status is 201
  
            
            # Your successful logic here from backend
            else
  
        
        # Your failure logic here from backend
        else
  
        
        # Failed to tokenize, your error logic here
        
  
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


$ ->
  new CreditCard
