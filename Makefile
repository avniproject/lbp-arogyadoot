setup_impl:
	curl -X POST http://$(server):$(port)/catchments -d @catchments.json -H "Content-Type: application/json"
	curl -X POST http://$(server):$(port)/forms -d @registrationForm.json -H "Content-Type: application/json"

deployable :
	rm -rf output/impl
	mkdir output/impl
	cp registrationForm.json catchments.json deploy.sh output/impl
	cd output/impl && tar zcvf ../openchs_impl.tar.gz *.*

play:
	echo $(server)