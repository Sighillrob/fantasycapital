
# View of an entry summary row at the top of gamecenter (ie where all users' entries are listed).

class Main.Views.EntrySummarysView extends Backbone.View

  initialize: (args) ->
    @template = $("#entry-summary-template").html()
    @entrysummarys_coll = args.entrysummarys_coll
    @listenTo(@entrysummarys_coll, 'reset', @changeentry)
    @render()

  render: () ->
    rendered = ""
    @entrysummarys_coll.each( (entrysummary) ->
        rendered += _.template(this.template, {entrysummary: entrysummary, user_img: window.user_img_placeholder})
      , this )
    $(@el).html(rendered)
    return this

  changeentry: () ->
    @render()
