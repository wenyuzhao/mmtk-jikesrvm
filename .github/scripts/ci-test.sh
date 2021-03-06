set -xe

# To JikesRVM folder
cd repos/jikesrvm

# Test BaseBase builds
# Only run one test

# RBaseBaseNoGC
python scripts/testMMTk.py -j $JAVA_HOME -g RBaseBaseNoGC -a "Xms1024M Xmx1024M" -- --use-third-party-heap=../../ --use-third-party-build-configs=../../jikesrvm/build/configs --use-external-source=../../jikesrvm/rvm/src
# RBaseBaseSemiSpace
python scripts/testMMTk.py -j $JAVA_HOME -g RBaseBaseSemiSpace -a "Xms75M Xmx75M" -- --use-third-party-heap=../../ --use-third-party-build-configs=../../jikesrvm/build/configs --use-external-source=../../jikesrvm/rvm/src

# Test FastAdaptive builds
# Run all possible dacapo benchmarks

# RFastAdaptiveNoGC (use largest heap possible)
./bin/buildit localhost RFastAdaptiveNoGC -j $JAVA_HOME --answer-yes --use-third-party-heap=../../ --use-third-party-build-configs=../../jikesrvm/build/configs --use-external-source=../../jikesrvm/rvm/src
./dist/RFastAdaptiveNoGC_x86_64-linux/rvm -Xms3G -Xmx3G -jar benchmarks/dacapo-2006-10-MR2.jar antlr
./dist/RFastAdaptiveNoGC_x86_64-linux/rvm -Xms3G -Xmx3G -jar benchmarks/dacapo-2006-10-MR2.jar fop
./dist/RFastAdaptiveNoGC_x86_64-linux/rvm -Xms3G -Xmx3G -jar benchmarks/dacapo-2006-10-MR2.jar luindex
./dist/RFastAdaptiveNoGC_x86_64-linux/rvm -Xms3G -Xmx3G -jar benchmarks/dacapo-2006-10-MR2.jar pmd

# Running the GC tests with recompilation disabled. See https://github.com/mmtk/mmtk-jikesrvm/issues/36
RVM_OPTIONS='-X:aos:initial_compiler=opt -X:aos:enable_recompilation=false'

# RFastAdaptiveSemiSpace
./bin/buildit localhost RFastAdaptiveSemiSpace -j $JAVA_HOME --answer-yes --use-third-party-heap=../../ --use-third-party-build-configs=../../jikesrvm/build/configs --use-external-source=../../jikesrvm/rvm/src
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar antlr
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar bloat
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms150M -Xmx150M -jar benchmarks/dacapo-2006-10-MR2.jar eclipse
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar fop
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms200M -Xmx200M -jar benchmarks/dacapo-2006-10-MR2.jar hsqldb
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar jython
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar luindex
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar lusearch
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms75M -Xmx75M -jar benchmarks/dacapo-2006-10-MR2.jar pmd
./dist/RFastAdaptiveSemiSpace_x86_64-linux/rvm $RVM_OPTIONS -Xms100M -Xmx100M -jar benchmarks/dacapo-2006-10-MR2.jar xalan