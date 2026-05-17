MRuby::Build.new do |conf|
  conf.toolchain

  # Standard library set (mruby-time, mruby-string-ext, mruby-eval, etc).
  conf.gembox 'default'

  # `Time#strftime` is shipped with mruby but not part of the default gembox.
  # hola provision scripts rely on it for timestamp formatting.
  conf.gem core: 'mruby-strftime'
end
