const serverlessConfiguration = {
  service: 'todo-terraform',
  frameworkVersion: '2',
  custom: {
    webpack: {
      webpackConfig: './webpack.config.js',
      includeModules: {
        forceExclude: ['aws-sdk'],
        concurrency: 5,
        serializedCompile: true,
        packager: 'npm',
      },
    }
  },
  plugins: [
    'serverless-webpack',
  ],
  provider: {
    name: 'aws',
    runtime: 'nodejs14.x',
    region: 'us-east-1',
    profile: 'flo',
  },
};

module.exports = serverlessConfiguration;
