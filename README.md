# loadtest-plotter
Plot results produced by the npm module 'loadtest'.

A common task in server stress testing is to compare the server's performance by varying some paramater of requests, *concurrency* being the major one. Npm's [loadtest](https://www.npmjs.com/package/loadtest) module can run a load test on the selected HTTP or WebSockets URL. It provides control over different parameters including concurrency, total number of requests, etc.

This project takes results produced by individual *loadtest* tests and creates beautiful graphs which help in analysing server performance.

loadtest-plotter utilises python's seaborn library to make visually pleasing and informative plots.