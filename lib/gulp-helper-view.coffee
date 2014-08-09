{View} = require 'atom'
{BufferedProcess} = require 'atom'
Convert = require 'ansi-to-html'
converter = new Convert()
module.exports =
class GulpHelperView extends View
  @process: null
  @content: ->
    @div class: "gulp-helper tool-panel panel-bottom", =>
      @div class: "panel-heading affix", 'Gulp Output'
      @div class: "panel-body padded"

  initialize: (serializeState) ->
    atom.workspaceView.command "gulp-helper:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
      if @process
        @process.kill()
    else
      atom.workspaceView.prependToBottom(this)
      @runGulp()

  runGulp: ->
    if atom.project.getPath()
      atom.workspaceView.find('.gulp-helper .panel-body').html('')
      command = if process.platform = 'win32' then 'gulp' else '/usr/local/bin/gulp'
      args = ['--color', 'watch']
      options = {
          cwd: atom.project.getPath()
      }
      stdout = @gulpOut
      stderr = @gulpErr
      exit = @gulpErr
      @process = new BufferedProcess({command, args, options, stdout, stderr, exit})

  setScroll: ->
    gulpHelper = atom.workspaceView.find('.gulp-helper')
    gulpHelper.scrollTop(gulpHelper[0].scrollHeight)

  gulpOut: (output) =>
    for line in output.split("\n")
      stream = converter.toHtml(line);
      atom.workspaceView.find('.gulp-helper .panel-body').append "<div class='text-highighted'>#{stream}</div>"
    @setScroll()

  gulpErr: (code) =>
    atom.workspaceView.find('.gulp-helper .panel-body').append "<div class='text-error'>Error Code: #{code}</div>"
    @setScroll()

  gulpExit: (code) =>
    atom.workspaceView.find('.gulp-helper .panel-body').append "<div class='text-error'>Exited with error code: #{code}</div>"
    @setScroll()
