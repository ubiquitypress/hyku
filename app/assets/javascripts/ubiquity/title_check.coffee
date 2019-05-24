checkTitle = (ubiquityAlternativeTitleAry, ubiquityModel) ->
  host = window.document.location.host
  protocol = window.document.location.protocol
  fullHost = protocol + '//' + host + '/available_ubiquity_titles/check'
  $.ajax
    url: fullHost
    type: 'POST'
    data:
      'title': ubiquityAlternativeTitleAry
      'model_class': ubiquityModel
    success: (result) ->
      if result.data == 'true'
        $('.ubiquity-title-fail-message').html result.message + result.title_list
        $('.ubiquity-title-fail-message').show()
      else
        $('.ubiquity-title-success-message').html result.message
        $('.ubiquity-title-success-message').show()
      return
    error: ->
  return

$(document).on 'turbolinks:load', ->
  $('.ubiquity-title-checker').click (event) ->
    event.preventDefault()
    $('.ubiquity-title-success-message').hide()
    $('.ubiquity-title-fail-message').hide()
    ubiquityModel = $(this).attr('data-ubiquity-model')
    ubiquityTitle = $('.ubiquity-title').val()
    ubiquityAlternativeTitleAry = $('.ubiquity-alternative-title').map(->
      $(this).val()
    ).get()
    ubiquityAlternativeTitleAry.push ubiquityTitle
    if ubiquityAlternativeTitleAry.length != 0
      checkTitle ubiquityAlternativeTitleAry, ubiquityModel
    return
  return
