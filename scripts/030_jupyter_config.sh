#!/bin/bash

# Only run on the master node
ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
if [[ "${ROLE}" == 'Master' ]]; then
	source /etc/profile.d/conda_config.sh

	# Install iPython Notebook and create a profile
	cd
	mkdir IPythonNB
	cd IPythonNB
	ipython profile create default
	


	# Set up configuration for iPython Notebook
	echo "c = get_config()" >  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.ip = '*'" >>  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.open_browser = False"  >>  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.port = 8123" >>  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.token = ''" >>  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.password = ''" >>  /root/.ipython/profile_default/ipython_notebook_config.py

	# Setup script for iPython Notebook so it uses the cluster's Spark
	cat > /root/.ipython/profile_default/startup/00-pyspark-setup.py <<'_EOF'
import os
import sys
spark_home = '/usr/lib/spark/'
os.environ["SPARK_HOME"] = spark_home
sys.path.insert(0, os.path.join(spark_home, 'python'))
sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.10.3-src.zip'))
sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.10.4-src.zip'))
sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.9-src.zip'))
exec(compile(open(os.path.join(spark_home, 'python/pyspark/shell.py')).read(), os.path.join(spark_home, 'python/pyspark/shell.py'), 'exec'))
_EOF

	# Start iPython Notebook on port 8123
	# add it to starting scripts
	touch /etc/init.d/start_jupyter.sh
	chmod +x /etc/init.d/start_jupyter.sh

	touch /var/log/python_notebook.log
	echo "mkdir -p /workspace" >> /etc/init.d/start_jupyter.sh
	echo "cd /workspace" >> /etc/init.d/start_jupyter.sh
	echo "nohup jupyter notebook --allow-root --config=/root/.ipython/profile_default/ipython_notebook_config.py &> /var/log/python_notebook.log &" >> /etc/init.d/start_jupyter.sh
	/etc/init.d/start_jupyter.sh

	echo "Jupyter notebook started"

	gsutil -m cp -r gs://ai-bucket/notebooks /workspace
fi
