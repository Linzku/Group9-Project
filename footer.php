</div>
  </div>
  <div class="row">
<footer style="background-color: rgb(65, 7, 109); color: white;">

  <!-- Copyright -->
  <div class="footer-copyright text-center py-3">© 2020 Copyright
  </div>
  <!-- Copyright -->

<?php 
$filename = basename($_SERVER['PHP_SELF']);
$mdate = filemtime($filename);
$time = date("F j, Y, g:i a", $mdate);
echo  "<div class=\"footer-copyright text-center py-3\">". $filename . " was last modified on: " . $time . "</div>"?>

</footer></div>
</div>

<!-- Optional JavaScript -->
      <!-- jQuery first, then Popper.js, then Bootstrap JS -->
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js" integrity="sha384-w76AqPfDkMBDXo30jS1Sgez6pr3x5MlQ1ZAGC+nuZB+EYdgRZgiwxhTBTkF7CXvN" crossorigin="anonymous"></script>
    </body>
    </html>
