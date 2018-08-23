#!/bin/sh
echo "Getting certificate";

# function to add domains
add_domains() {
  domains="$DOMAIN"
  for i in $TENANTS;
  do
    domains="$domains,$i.$DOMAIN";
  done
  echo "$domains";
}

domains=$(add_domains);
echo ${domains};

test_cert="";
if [ "$USE_TEST_CERT" = true ] ; then
    test_cert="--test-cert";
fi

certbot certonly -n --agree-tos --no-eff-email --keep $test_cert \
  --email "$EMAIL" \
  --webroot --webroot-path=/data/letsencrypt \
  -d "$domains"
