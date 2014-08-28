module.exports = function (grunt) {
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-shell');
 
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        shell: {
			tsc: {
			    command: __dirname + '/node_modules/.bin/tsc --target ES5 -out "bin/index.js" @compile.txt'
			}
		},
        watch: {
            files: __dirname + '/*.ts',
            tasks: ['shell']
        }
    });

    grunt.registerTask('default', ['shell']);
	grunt.registerTask('watch', ['watch']); //Has issues, shouldn't use
	grunt.registerTask('tsc', ['shell']);
}
