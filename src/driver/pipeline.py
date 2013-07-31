"""
pipeline.py

Classes and routines for describing steps in the pipeline and how they can be
implemented as MapReduce steps.
"""

import hadoop

class Aggregation(object):
    """ Encapsulates information about the aggregation before a reducer. """
    
    def __init__(self, ntasks, ntasksPerReducer, nbin, nsort):
        self.ntasks = ntasks
        self.ntasksPerReducer = ntasksPerReducer
        assert nsort >= nbin
        self.nbin = nbin
        self.nsort = nsort
    
    def toHadoopArgs(self, config):
        begArgs, endArgs = [], []
        v = config.hadoopVersion
        confArg = hadoop.confArg(v)
        if self.ntasks is not None:
            begArgs.append('"%s", "mapred.reduce.tasks=%d",' % (confArg, self.ntasks))
        else:
            assert self.ntasksPerReducer is not None
            begArgs.append('"%s", "mapred.reduce.tasks=%d",' % (confArg, self.ntasksPerReducer * config.nReducers))
            begArgs.append('"%s", "%s",' % (confArg, hadoop.keyFields(v, self.nbin)))
            begArgs.append('"%s", "stream.num.map.output.key.fields=%d",' % (confArg, self.nsort))
            endArgs.append('"-partitioner", "org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner",')
        return begArgs, endArgs

class PipelineConfig(object):
    """ Information about the particular system we're going to run on, which
        changes some of the exact arguments we use """
    
    def __init__(self, hadoopVersion, waitOnFail, emrStreamJar, nReducers, emrLocalDir, preprocCompress, out):
        # Hadoop version used on EMR cluster
        self.hadoopVersion = hadoopVersion
        # Whether to keep the EMR cluster running if job fails
        self.waitOnFail = waitOnFail
        # Path to streaming jar
        self.emrStreamJar = emrStreamJar
        # Total number of reducers that can run simultaneously
        self.nReducers = nReducers
        # Local directory where reference jar and scripts have been installed
        self.emrLocalDir = emrLocalDir
        # Whether & how to compress output from preprocessor
        self.preprocCompress = preprocCompress
        # Output URL
        self.out = out

class Step(object):
    """ Encapsulates a single step of the pipeline, i.e. a single
        MapReduce/Hadoop job """
    
    def __init__(self, name, inp, output, inputFormat, aggr, mapper, reducer):
        self.name = name
        self.input = inp
        self.output = output
        self.inputFormat = inputFormat
        self.aggr = aggr
        self.mapper = mapper
        self.reducer = reducer
    
    def toHadoopCmd(self):
        raise RuntimeError("toHadoopCmd not yet implemented")
    
    def toEmrCmd(self, config):
        lines = []
        lines.append('{')
        lines.append('  "Name" : "%s",' % self.name)
        lines.append('  "ActionOnFailure" : "%s",' % ("CANCEL_AND_WAIT" if config.waitOnFail else "TERMINATE_JOB_FLOW"))
        lines.append('  "HadoopJarStep": {')
        lines.append('    "Jar": "%s",' % config.emrStreamJar)
        lines.append('    "Args": [')
        
        begArgs, endArgs = [], []
        if self.aggr is not None:
            begArgs, endArgs = self.aggr.toHadoopArgs(config)
        
        endArgs.append('"-input", "%s",' % self.input)
        endArgs.append('"-output", "%s",' % self.output)
        endArgs.append('"-mapper", "%s",' % self.mapper)
        
        if self.reducer is not None:
            endArgs.append('"-reducer", "%s",' % self.reducer)
        else:
            begArgs.append('"%s", "mapred.reduce.tasks=0",' % hadoop.confArg(config.hadoopVersion))
        
        if self.inputFormat is not None:
            endArgs.append('"-inputformat", "%s",' % self.inputFormat)
        
        for a in begArgs + endArgs: lines.append('      ' + a)
        
        # Remove trailing comma
        lines[-1] = lines[-1][:-1]
        
        # Add cache files for any tools used by this job
        
        lines.append('    ]')
        lines.append('  }')
        lines.append('}')
        
        return '\n'.join(lines)
