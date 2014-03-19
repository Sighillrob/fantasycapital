
# View of an entry summary row at the top of gamecenter (ie where all users' entries are listed).

class Main.Views.EntrySummarysView extends Backbone.View

  initialize: (args) ->
    @template = $("#entry-summary-template").html()
    @entries_coll = args.entries_coll
    @listenTo(@entries_coll, 'reset', @changeentry)
    @render()

  render: () ->
    rendered = ""
    @entries_coll.each( (entry) ->
        rendered += _.template(this.template, {entry: entry, user_img: window.user_img_placeholder})
      , this )
    $(@el).html(rendered)
    return this

  changeentry: () ->
    @render()
