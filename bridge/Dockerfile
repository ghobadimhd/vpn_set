FROM nginx

COPY entrypoint.sh /usr/local/bin/
RUN chmod -R a+x /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
# CMD bash -c "tail -f /dev/null"