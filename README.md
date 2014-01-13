## heroku-domains-extended

Gives DNS advice for domains on heroku applications

```
$ heroku plugins:install https://github.com/neilmiddleton/heroku-domains-extended
```

Usage:

```
$ heroku domains:verify www.neilmiddleton.com -a neilmiddleton

HTTP:   Domain should CNAME/ALIAS neilmiddleton.herokuapp.com
HTTPS:  Not available on this domain.  Add an SSL:Endpoint.

Routing...... OK
done
```

