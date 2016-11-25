module.exports = function(grunt) {

  // The target directory for the final build product.
  var targetDirectory = 'out';

  grunt.initConfig({
    appengine: {
      app: {
        root: targetDirectory,
        manageScript: [process.env.HOME,
                       'bin', 'google_appengine', 'appcfg.py'].join('/'),
        runFlags: {
          port: 8080
        },
        runScript: [process.env.HOME,
                    'bin', 'google_appengine', 'dev_appserver.py'].join('/')
      }
    },

    build: grunt.file.readJSON('config.json'),

    clean: [targetDirectory],

    closureBuilder: {
      options: {
        closureLibraryPath: 'closure-library',
        compile: true,
        compilerFile: ['closure-compiler', 'target',
                       'closure-compiler-v20160517.jar'].join('/'),
        compilerOpts: {
          compilation_level: grunt.option('dev') ?
            'SIMPLE_OPTIMIZATIONS' : 'ADVANCED_OPTIMIZATIONS'
        },
        namespaces: 'app',
      },
      js: {
        src: ['closure-library', 'js',
              [targetDirectory, 'generated', 'js'].join('/')],
        dest: [targetDirectory, 'static', 'app.js'].join('/'),
      }
    },

    closureSoys: {
      js: {
        src: ['templates', 'soy', '**', '*.soy'].join('/'),
        soyToJsJarPath: ['closure-templates', 'target',
                         'soy-2016-08-25-SoyToJsSrcCompiler.jar'].join('/'),
        outputPathFormat: [targetDirectory, 'generated', 'js',
                           'app.soy.js'].join('/'),
        options: {
          allowExternalCalls: false,
          shouldGenerateJsdoc: true,
          shouldProvideRequireSoyNamespaces: true
        }
      },
      py: {
        src: ['templates', 'soy', '**', '*.soy'].join('/'),
        soyToJsJarPath: ['closure-templates', 'target',
                         'soy-2016-08-25-SoyToPySrcCompiler.jar'].join('/'),
        outputPathFormat: [targetDirectory, 'generated',
                           '{INPUT_FILE_NAME_NO_EXT}.py'].join('/'),
        options: {
          runtimePath: 'soy',
        }
      }
    },

    copy: {
      source: {
        cwd: 'src/',
        dest: [targetDirectory, ''].join('/'),
        expand: true,
        src: '**'
      },
      soyutils_js: {
        cwd: ['closure-templates', 'javascript'].join('/'),
        dest: [targetDirectory, 'generated', 'js'].join('/'),
        expand: true,
        src: 'soyutils_usegoog.js'
      },
      soyutils_py: {
        cwd: ['closure-templates', 'python'].join('/'),
        dest: [targetDirectory, 'soy', ''].join('/'),
        expand: true,
        src: '*.py'
      },

      static: {
        cwd: 'static',
        dest: [targetDirectory, 'static', ''].join('/'),
        expand: true,
        src: '**'
      },
      templates: {
        cwd: 'templates',
        dest: [targetDirectory, 'templates', ''].join('/'),
        expand: true,
        src: '**'
      },
      third_party_js: {
        cwd: ['third_party', 'js'].join('/'),
        dest: [targetDirectory, 'static', 'third_party', ''].join('/'),
        expand: true,
        src: '**'
      },
      third_party_py: {
        cwd: ['third_party', 'py'].join('/'),
        dest: [targetDirectory, ''].join('/'),
        expand: true,
        src: '**'
      }
    },
  });

  grunt.loadNpmTasks('grunt-appengine');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-closure-soy');
  grunt.loadNpmTasks('grunt-closure-tools');

  grunt.registerTask('init_py', 'Generates __init__.py', function(dir) {
    grunt.file.write([targetDirectory, dir, '__init__.py'].join('/'),
                     '');
  });
  grunt.registerTask('nop', 'no-op', function() {});

  grunt.registerTask('yaml', 'Generates app.yaml',
      function() {
        var appid = grunt.option('appid') ||
                    grunt.config.get('build.appid', false);

        if (typeof(appid) !== 'string' || appid.length == 0) {
          grunt.fatal('no appid');
        }

        var uncommitedChanges = false;
        var done = this.async();

        var logCallback = function(error, result, code) {
          if (code != 0) {
            grunt.log.writeln('git log error: ' + result);
            done(false);
          }
          var hash = String(result).split(' ')[0].substr(0, 16);
          var versionString = hash + (uncommitedChanges ? '-dev' : '');
          var yamlData = grunt.file.read('app.yaml.base');
          yamlData = yamlData.replace('__APPLICATION__', appid);
          yamlData = yamlData.replace('__VERSION__', versionString);
          grunt.log.writeln('Generating yaml for application: ' + appid);
          grunt.file.write([targetDirectory, 'app.yaml'].join('/'), yamlData);
          done();
        };

        var statusCallback = function(error, result, code) {
          if (code != 0) {
            grunt.log.writeln('git status error: ' + result);
            done(false);
          }
          var pattern = /nothing to commit, working (directory|tree) clean/i;
          if (!pattern.test(String(result))) {
            uncommitedChanges = true;
          }
          grunt.util.spawn(
              {cmd: 'git', args: ['log', '--format=oneline', '-n', '1']},
              logCallback);
        };

        grunt.util.spawn({cmd: 'git', args: ['status']}, statusCallback);
        });

  grunt.registerTask('default',
      ['copy:source', 'copy:static', 'copy:templates',
       'copy:third_party_js', 'copy:third_party_py',
      grunt.config.get('build.use_closure_templates') ?
                       'copy:soyutils_js' : 'nop',
      grunt.config.get('build.use_closure_templates') ?
                       'closureSoys:js' : 'nop',
      grunt.config.get('build.use_closure') ? 'closureBuilder' : 'nop',
      grunt.config.get('build.use_closure_py_templates') ?
                       'copy:soyutils_py' : 'nop',
      grunt.config.get('build.use_closure_py_templates') ?
                       'init_py:soy' : 'nop',
      grunt.config.get('build.use_closure_py_templates') ?
                       'init_py:generated' : 'nop',
      grunt.config.get('build.use_closure_py_templates') ?
                       'closureSoys:py' : 'nop',
      'yaml']);
};

