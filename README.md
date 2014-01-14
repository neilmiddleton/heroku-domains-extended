## heroku-domains-extended

Gives DNS advice for domains on heroku applications

```
$ heroku plugins:install https://github.com/neilmiddleton/heroku-domains-extended
```

### domains:add

```
$ heroku domains:add www.neilmiddleton.com -a neilmiddleton
Adding www.neilmiddleton.com to neilmiddleton... done

HTTP:   Domain should CNAME/ALIAS neilmiddleton.herokuapp.com
HTTPS:  Not available on this domain.  Add an SSL:Endpoint.
```

### domains:dns

```
$  h domains:dns microsoft.com -a neilmiddleton
HTTP:   Domain should CNAME/ALIAS neilmiddleton.herokuapp.com
HTTPS:  Not available on this domain.  Add an SSL:Endpoint.

Users of apex (root) domains should read https://devcenter.heroku.com/articles/apex-domains
```