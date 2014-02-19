fantasysport = angular.module("fantasysport")

fantasysport.filter('truncate', ->
  return (text, length, end) ->
    if (isNaN(length))
      length = 12
    if (end == undefined)
      end = "..."
    if(text)
      if (text.length <= length)
        return text
      else 
        return String(text).substring(0, length) + end
        )