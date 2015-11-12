module.exports = function(grunt) {

  grunt.initConfig({
    browserify: {
      dist: {
        options: {
          transform: [["babelify", {presets: "es2015"}]]
        },
        files: {
          "bundle.js": "src/main.js"
        }
      }
    },
    htmlmin: {
      dist: {
        options: {
          removeComments: true,
          collapseWhitespace: true
        },
        files: [{
          "expand": true,
          "cwd": "src/",
          "src": ["**/*.html"],
          "dest": "",
          "ext": ".html"
        }]
      }
    },
    connect: {
      server: {
        options: {
          port: 8080,
          base: ''
        }
      },
    },
    copy: {
      main: {
        files: [
          {expand: true, cwd: 'src/css', src: ['*.css'], dest: 'css'}
          // {expand: true, cwd: 'data', src: ['*'], dest: 'build/data'}
        ]
      }
    },
    watch: {
      scripts: {
        files: "src/*.js",
        tasks: ["browserify"]
      },
      html: {
        files: "src/*.html",
        tasks: ["htmlmin"]
      },
      css: {
        files: "src/css/*.css",
        tasks: ["copy"]
      },
      data: {
        files: "data/*",
        tasks: ["copy"]
      }
    }
  });

  grunt.loadNpmTasks("grunt-browserify");
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-htmlmin");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-contrib-connect");

  grunt.registerTask("default", ["browserify", "copy", "htmlmin", "connect",  "watch"]);
};
