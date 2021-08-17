FROM ruby:alpine

COPY dot.rb /usr/app/

EXPOSE 53/udp
CMD ["ruby", "/usr/app/dot.rb"]

