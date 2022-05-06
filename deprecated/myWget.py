import requests
import argparse
import os.path
import sys
import zipfile
import tarfile

def download_file(url, outputdir):
	local_filename = outputdir + url.split('/')[-1]
	# NOTE the stream=True parameter
	# python -mrequests.certs
	r = requests.get(url, stream=True, verify=True, allow_redirects=True)
	if r.history:
		print "Request was redirected"
		for resp in r.history:
			print resp.status_code, resp.url
		print "Final destination:"
		print r.status_code, r.url
	else:
		print "Request was not redirected"
		print r.status_code, r.url
	print r.headers
	# sometimes content-length is not provided
	#file_size = int(r.headers['content-length']) 
	file_size = len(r.content)
	print "Downloading: %s Bytes: %s" % (local_filename, file_size)
	with open(local_filename, 'wb') as f:
		file_size_dl = 0
		for chunk in r.iter_content(chunk_size=1024): 
			if chunk: # filter out keep-alive new chunks
				file_size_dl += len(chunk)
				f.write(chunk)
				# status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
				# status = status + chr(8)*(len(status)+1)
				# print status,
	return local_filename
	
parser = argparse.ArgumentParser(description='Process some files.')
parser.add_argument("-u", "--url", type=str, required=True, help='URL of file to download')
parser.add_argument("-n", "--name", type=str, required=True, help='NAME of the downloaded file')
parser.add_argument("-e", "--extracted_dir", type=str, required=True, help='DIRECTORY of the extracted file')
parser.add_argument("-o", "--output_dir", type=str, default="./", help='output directory (default: current directory)')
parser.add_argument("-r", "--rename", help='RENAME the dowloaded file using the --name argument', action="store_true")
args=parser.parse_args()

print args

url = args.url
outdir = args.output_dir
abspath = os.path.abspath(outdir)
abspath = os.path.join(abspath, '')
file_dl = os.path.join(abspath, args.name)
extractdir = os.path.join(abspath, args.extracted_dir)
print 'absolute output path="%s"' % abspath
# create the download directory if it doesn't exist
if not os.path.exists(abspath):
	os.makedirs(abspath)
if not os.path.exists(abspath):
	print 'output path "%s" does not exist' % abspath
	sys.exit(1)

# does the downloaded file already exist?
if not os.path.exists(file_dl):
	file_dl = download_file(url, abspath)
	if args.rename:
		#build new name
		path = os.path.dirname(file_dl)
		newname = os.path.join(path, args.name)
		os.rename(file_dl, newname)
		file_dl = newname
else:
	print 'File already downloaded'
	try_again=False
	if file_dl.lower().endswith('.zip'):
		if zipfile.is_zipfile(file_dl):
			the_zip_file = zipfile.ZipFile(file_dl)
			ret = the_zip_file.testzip()
			if ret is not None:
				print "First bad file in zip: %s" % ret
				try_again=True
			else:
				print "Zip file is good."
		else:
			print "File is not a valid zip file."
			try_again=True
		if try_again:
			# lets tyr the download again
			print "Trying download again..."
			file_dl = download_file(url, abspath)
			if args.rename:
				#build new name
				path = os.path.dirname(file_dl)
				newname = os.path.join(path, args.name)
				os.rename(file_dl, newname)
				file_dl = newname
	
# does the extracted directory already exist?
#if not os.path.exists(extractdir):
if file_dl.lower().endswith('.zip'):
	with zipfile.ZipFile(file_dl, "r") as z:
		# may need this to handle very long file names on Windows (MAX_PATH=260)
		extractdir = u'\\\\?\\' + extractdir
		print 'Extracting %s to %s' % (file_dl, extractdir)
		z.extractall(extractdir)
elif file_dl.lower().endswith('tar.gz'):
	with tarfile.open(file_dl, 'r:gz') as z:
		print 'Extracting %s to %s' % (file_dl, extractdir)
		z.extractall(extractdir)
elif file_dl.lower().endswith('.patch'):
		print 'Patch file %s downloaded to %s' % (file_dl, extractdir)
else:
	with tarfile.open(file_dl, 'r:*') as z:
		print 'Extracting %s to %s' % (file_dl, extractdir)
		z.extractall(extractdir)
#else:
#	print 'File already extracted'
