all: clean serve_drafts

serve:
	./docker_startup.sh
clean:
	docker run --rm -v $PWD:/srv/jekyll jekyll/builder:pages jekyll clean;
	rm -f o2r_project_website_and_blog.pdf;
	rm -f o2r_project_website_and_blog_git-repository.zip;

build: clean
	docker run --rm -v $PWD:/srv/jekyll jekyll/builder:pages jekyll build

save_all_content_to_pdf:
	wkhtmltopdf \
	--outline \
	--javascript-delay 20000 --no-stop-slow-scripts \
	--margin-top 20mm \
	--margin-bottom 20mm \
	--footer-html http://127.0.0.1:4000/public/pdf_footer.html \
	toc http://127.0.0.1:4000/all_content/ o2r_project_website_and_blog.pdf

capture_pdf:
	make serve & ( sleep 5 && make save_all_content_to_pdf ; echo "Captured PDF"; )

capture_zip:
	git archive --format=zip HEAD -o o2r_project_website_and_blog_git-repository.zip

update_zenodo_deposit: build capture_pdf capture_zip
	python3 $(shell pwd)/zenodo_release.py;
	pkill -f jekyll;

.PHONY: update_zenodo_deposit
