# /usr/bin/env bash
cat element-desktop/yarn.lock > bom.lock
echo "" >> bom.lock
cat element-web/yarn.lock >> bom.lock
echo "" >> bom.lock
cat matrix-js-sdk/yarn.lock >> bom.lock
echo "" >> bom.lock
cat matrix-react-sdk/yarn.lock >> bom.lock
echo "" >> bom.lock

# matrix-seshat
cat << EOF >> bom.lock
matrix-seshat@2.3.0:
  version "2.3.0"
  resolved "https://github.com/matrix-org/seshat/archive/refs/heads/master.tar.gz"
  integrity sha512-y4xtZViRX/h0zczl5hiqWyFNK7np0vVujQ/l47g1Mm7B7mDTHAneSSy/d5GADeUIsezZyvT3qKhSCwSSyqS8Xw==
  dependencies:
    sqlcipher "~m1"
    openssl "~1.1.1f"

sqlcipher@m1:
  version "m1"
  resolved "https://github.com/SchildiChat/sqlcipher/archive/refs/heads/m1.tar.gz"
  integrity sha512-1Nk7J0dQyVedFLqnxUJQWrf/VBsUsfC5vAYaHDH3LRbWarfKDGYduZrhdBuzgAF+kMA237HaDt9Tq+CcXV0EJA==

openssl@1.1.1f:
  version "1.1.1f"
  resolved "https://www.openssl.org/source/openssl-1.1.1f.tar.gz"
  integrity sha512-sAvZta1SmPvO7sa7GcGrDBBspc+zEXhJfFi/fg4M8w/MGcIPhOI68xzBJr8kR9Pk+EYduXuvp7149pVhky8ADA==
EOF
echo "" >> bom.lock

# keytar
cat << EOF >> bom.lock
keytar@^5.6.0:
  version "5.6.0"
  resolved "https://github.com/atom/node-keytar/archive/refs/tags/v5.6.0.tar.gz"
  integrity sha512-dPdXLrm8AlqooT0ZS7y/mYif0DmQXoGGrqomwfl6ugIEHlpL1D+hJYhjyMC00TK924vOGD1a6OhDS2+RKEffXA==
  dependencies:
    libsecret "~0.20.3"

libsecret@0.20.3:
  version "0.20.3"
  resolved "https://gitlab.gnome.org/GNOME/libsecret/-/archive/0.20.3/libsecret-0.20.3.tar.gz"
  integrity sha512-tbD1jNKEEW9bPWuyd5YZ68eQjHhXOsy5PseVwleWYMEXgrrPPGnGGrLzSFUXRzNulFceLMeUG49Qr1rnyvfa1A==
EOF
