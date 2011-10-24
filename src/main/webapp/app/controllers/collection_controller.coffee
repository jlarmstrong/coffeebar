define [ 
  "frameworks"
], ->

  # Keeps a Collection Model synchronized
  # with a collection of child controlls. Which
  # get rendered and appended to the element.
  #
  # Construct with:
  # {
  #   collection:       The collection model which will be rendered
  #   child_control: function(model) that reurns a new Controller 
  #                     to render the child model
  # }
  #
  CollectionController = CoffeeBar.Controller.extend
    initialize: ->
      @collection = @options.collection if @options.collection 
      @child_control = @options.child_control if @options.child_control 
      
      @child_controls = {}
      for model in @collection.models
        @on_add(model)
      
      @collection.bind "reset", => @on_reset()
      @collection.bind "add", (model)=> @on_add(model)
      @collection.bind "remove", (model)=> @on_remove(model.id)
      
    render: ->
      $(@el).empty()
      for id,child of @child_controls
        $(@el).append( child.control.render().el )
      @
      
    on_add: (model)->
      child = 
        model:model
        control: @child_control(model)
      @child_controls[model.id] = child
      $(@el).append(child.control.render().el)
      
    on_remove: (id)->
      child = @child_controls[id]
      if child
        delete @child_controls[id]
        $(child.control.el).remove()
        
    on_reset: (options)->
      new_set = _.pluck(@collection.models, "id")
      old_set = _.keys(@child_controls)
      added = _.difference(new_set, old_set)
      removed = _.difference(old_set, new_set)
      for id in removed
        @on_remove(id)
      for id in added
        @on_add(@collection.get(id))

