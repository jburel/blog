all: clean serve_drafts

serve:
	docker run --rm -p 4000:4000 -v $PWD:/srv/jekyll jekyll/builder:pages jekyll server -w

clean:
	docker run --rm -v $PWD:/srv/jekyll jekyll/builder:pages jekyll clean;
	rm -f o2r_project_website_and_blog.pdf;
	rm -f o2r_project_website_and_blog_git-repository.zip;

build: clean
	docker run --rm -v $PWD:/srv/jekyll jekyll/builder:pages jekyll build

save_content_to_pdf:
	weasyprint http://127.0.0.1:4000/ blog.pdf

capture_pdf:
	make serve & ( sleep 5 && make save_content_to_pdf ; echo "Captured PDF"; )

capture_zip:
	git archive --format=zip HEAD -o blog_git-repository.zip

update_zenodo_deposit: build capture_pdf capture_zip
	python3 $(shell pwd)/zenodo_release.py;
	pkill -f jekyll;

.PHONY: update_zenodo_deposit
