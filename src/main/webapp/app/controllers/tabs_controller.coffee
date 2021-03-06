#
# Copyright (C) 2009-2011 the original author or authors.
# See the notice.md file distributed with this work for additional
# information regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define [
  "models/app"
  "frameworks"
], (app)->

  CoffeeBar.Controller.extend
    initialize: ->
      @state = new CoffeeBar.Model
      @tabs = new CoffeeBar.Collection
      tabs = for id,value of @options.tabs
        value.id = id
        value
      @tabs.reset(tabs)
      @state.set({tab:@options.tab || @options.tabs[0].id})
      @tabs.bind "reset", => @render()
      
    select: (tab)->
      @state.set({tab: tab})
      
    render_part: (value)->
      switch typeof(value)
        when 'string' then value
        when 'function' then @render_part(value(@))
        else value.render().el
        
    render: ->

      tab_menu = $(@make("ul", {class:"tabs"}))
      tab_page = $(@make("div"))

      $(@el).each ->
        $(@).empty()
        $(@).append(tab_menu)
        $(@).append(tab_page)

      for model in @tabs.models
        closure = => 
          item = model.toJSON()
          menu_item = $(@make("li"))
          menu_a = $(@make("a", item.a))
          label = @render_part(item.label)
          menu_item.each -> 
            menu_a.append(label)
            $(@).append(menu_a)

          update_active = =>
            if item.id == @state.get("tab")
              if @active_item != item
                @active_item = item
                menu_item.addClass("active")
                page = @render_part(item.page)
                tab_page.each ->
                  $(@).empty();
                  $(@).append( page )
            else
              menu_item.removeClass("active")
              
          update_active()
          menu_item.click => 
            app.router.navigate(item.route) if item.route
            @state.set({tab: item.id})
          @state.bind "change", => update_active()
          tab_menu.each -> $(@).append(menu_item)

        closure()
      @
