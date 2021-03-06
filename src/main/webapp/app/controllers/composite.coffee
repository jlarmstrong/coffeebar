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
  "frameworks"
], ->
  CoffeeBar.Controller.extend
    
    initialize: ->
      @children = new CoffeeBar.Collection()
      @children.add(@options.children) if @options.children?
      @children.bind "reset", => @render()
      @children.bind "remove", (model)=> @render()
      @children.bind "add", (model)=> @on_add(model)
      
    render: ->
      $(@el).empty()
      for child in @children.models
        @on_add(child)
      @

    on_add: (child)->
      child_el = @render_part(child.toJSON())
      $(@el).append(child_el)

    render_part: (value)->
      switch typeof(value)
        when 'string' then value
        when 'function' then @render_part(value(@))
        else value.render().el

    poll: ->
      for child in @children.toJSON()
        child.poll() if child.poll?
      
