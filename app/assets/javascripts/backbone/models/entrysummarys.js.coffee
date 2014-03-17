
# An entry summary row at the top of gamecenter (ie where all users' entries are listed).
class Main.Models.EntrySummary extends Backbone.Model
  paramRoot: 'entry'

  initialize: () ->
    console.log "HI"

class Main.Collections.EntrySummarysCollection extends Backbone.Collection
  model: Main.Models.EntrySummary
