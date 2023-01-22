cd ..
echo "> # Main App # lib:"
find ./lib -name "*.dart" -type f|xargs wc -l | grep total
echo "> # Example:"
find ./example/lib -name "*.dart" -type f|xargs wc -l | grep main
echo "> # Should have nothing after this line, as examples are single files in pub.dev"
find ./example/lib -name "*.dart" -type f|xargs wc -l | grep total
