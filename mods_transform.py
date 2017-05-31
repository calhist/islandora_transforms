# run MODS xml through cleanup.xsl

import os, glob, lxml.etree as ET

source_path = 'mods\\'
out_path = 'dc\\'

xsl_filename = 'CHS_mods_to_dc.xsl'
xml_files = os.listdir(source_path)

print xml_files

for xml in xml_files:

	parser = ET.XMLParser(recover=True)
	dom = ET.parse(source_path+xml, parser)

	xslt = ET.parse(xsl_filename)
	transform = ET.XSLT(xslt)
	newdom = transform(dom)

	out = out_path+xml.replace('MODS', 'DC')

    # write out to new file
	with open(out, 'wb') as f:
		f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
		f.write(ET.tostring(newdom, pretty_print = True))
	print "Writing", out
print "All done!"