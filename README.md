GritHttp
========

GritHttp is a Sinatra application that provides a web JSON-based API to git repositories.

Git support is powered by Grit ruby library.

The main purpose of this application is to serve git objects data via simple api interface. If you're hosting git repositories on your own server this tool might be useful to provide an access to a third-party apps.

## Installation

The current state is not stable yet, but you can install this application by cloning the official git repo:

    $ git clone git://github.com/sosedoff/grit-http.git
    $ cd grit-http
    $ bundle install
    
## Configuration

Be default all configuration files are located in config/ folder under the app's root path.

There is a sample config file - config.yml.sample - where you can find more details and possible options.

Sample configuration:

    protection: true
    cache: false
    api_keys:
      - "SAMPLE_API_KEY"
    repositories:
      name: /path/to/repository
      
Options:

  * protection - Enable/disable API keys usage.
  * cache - Enable/disable caching
  * api_keys - List of your API keys. You can add as many as you want
  * repositories - List of full paths to your repositories. Each repository should have an alias, which is going to be used in requests.

## Deployment

The easiest way to get it up and running is to use Thin:

    $ cd grit-http
    $ thin start -e production
        
### Passenger Phusion + Nginx

Sample configuration:

    server {
      listen 80;
      server_name git.yourhost.com
      charset utf-8;
      passenger_enabled on;
      rack_env production;
      root /path/to/app/public;
    }

### Passenger Phusion + Nginx (Subroute)

If you already have an application deployed with passenger, its really easy to add another subroute to the app.

Just symlink grit-http's public folder into your current app's public folder. Name of this folder should be the same as you use in subroute.

    server {
      listen 80;
      server_name yourhost.com
      charset utf-8;
      passenger_enabled on;
      passenger_base_uri /git;
      rails_env production;
      root /path/to/your/existing/app;
    }

### Unicorn + Nginx

This section is coming soon.

## API Usage

API allowes you to make only GET requests, it is a read-only resource. It returns each response in JSON mode and UTF-8 encoding (except raw method).

Each response (failed and successful) from server has a structure:

    {
      "result": true,
      "data": {}
    }
    
Fields:

  * result - Indicates if request was successful. (true/false)
  * data - Primary container for api response.
  
If configuration option "protection" is set to true, all requests should have a "api_key" parameter added.

Unprotected request:

    curl -i "http://yourhost.com/"
    
Protected request:

    curl -i "http://yourhost.com/?api_key=KEY"

### Get repositories list

    GET /repositories

Response:

    {
      "result": true,
      "data": {
        "repositories": [
          "sinatra"
        ]
      }
    }

### Get repository information

    GET /repository?repo=sinatra
    
Response:

    {
      "result": true,
      "data": {
        "name": "sinatra",
        "bare": false,
        "filesize": 2035712
      }
    }
    
### Get repository branches (heads)

    GET /heads?repo=sinatra
  
Response:

    {
      "result": true,
      "data": [
        {
          "name": "master",
          "commit": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc"
        }
      ]
    }
    
### Get repository tags

    GET /tags?repo=sinatra
  
Response:

    {
      "result": true,
      "data": [
        {
          "name": "v1.3.0.e",
          "commit": "b5a310437e58a4d198216a41d76df60ef8186ac7"
        },
        {
          "name": "v1.3.0.d",
          "commit": "e9e6e737f913287340a82bdfd4fbaa47591d270f"
        }
      ]
    }

### Get repository refs (heads + tags)

    GET /refs?repo=sinatra
  
Response:

    {
      "result": true,
      "data": [
        {
          "name": "0.3.x",
          "commit": "4aefc7d024837e4a947fa978d621b4f019aeda1d"
        },
        {
          "name": "origin/0.3.x",
          "commit": "4aefc7d024837e4a947fa978d621b4f019aeda1d"
        }
      ]
    }
    
### Repository authors

    GET /authors?repo=sinatra
  
Response:

    {
      "result": true,
      "data": [
        {
          "name": "Konstantin Haase",
          "commits": 733,
          "position": 1
        },
        {
          "name": "Ryan Tomayko",
          "commits": 325,
          "position": 2
        }
      ]
    }


### Get repository commits

    GET /commits?repo=sinatra

Options:

  * head - Git head to use (default: master)
  * path - Path to fetch commits from
  * max_count - Limit amount of commits (default: 10, max: 25)
  * skip - Amount of commits to skip (default: 0)
  
Response:

    {
      "result": true,
      "data": {
        "head": "master",
        "path": null,
        "commits": [
          {
            "id": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc",
            "parents": [
              {
                "id": "9eb0dfe7dd0eaa48c5c55b6a1193f0c86f53f020"
              },
              {
                "id": "dd6fd9953b1a3568266e6a226c53093fb08a6817"
              }
            ],
            "tree": "a43281fdbc23304dcc7891321e4350e07c8cde41",
            "message": "Merge branch 'master' of github.com:sinatra/sinatra",
            "author": {
              "name": "Konstantin Haase",
              "email": "konstantin.mailinglists@googlemail.com",
              "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
            },
            "committer": {
              "name": "Konstantin Haase",
              "email": "konstantin.mailinglists@googlemail.com",
              "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
            },
            "authored_date": "2011-06-22T12:26:55-05:00",
            "committed_date": "2011-06-22T12:26:55-05:00"
          }
        ]
      }
    }
    
### Get a single commit

    GET /commit?repo=sinatra&id=a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc
    
Response:

    {
      "result": true,
      "data": {
        "head": "master",
        "path": null,
        "stats": {
          "id": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc",
          "additions": 0,
          "deletions": 0,
          "total": 0,
          "files": [
    
          ]
        },
        "diffs": [
          {
            "a_path": "lib/sinatra/base.rb",
            "b_path": "lib/sinatra/base.rb",
            "deleted_file": false,
            "new_file": false,
            "content": "--- a/lib/sinatra/base.rb\n+++ b/lib/sinatra/base.rb\n@@ -189,6 +189,8 @@\n       if filename\n         params = '; filename=\"%s\"' % File.basename(filename)\n         response['Content-Disposition'] << params\n+        ext = File.extname(filename)\n+        content_type(ext) unless response['Content-Type'] or ext.empty?\n       end\n     end\n "
          },
          {
            "a_path": "test/helpers_test.rb",
            "b_path": "test/helpers_test.rb",
            "deleted_file": false,
            "new_file": false,
            "content": "--- a/test/helpers_test.rb\n+++ b/test/helpers_test.rb\n@@ -576,6 +576,45 @@\n     end\n   end\n \n+  describe 'attachment' do\n+    def attachment_app(filename=nil)\n+      mock_app {       \n+        get '/attachment' do\n+          attachment filename\n+          response.write(\"<sinatra></sinatra>\")\n+        end\n+      }\n+    end\n+    \n+    it 'sets the Content-Type response header' do\n+      attachment_app('test.xml')\n+      get '/attachment'\n+      assert_equal 'application/xml;charset=utf-8', response['Content-Type']\n+      assert_equal '<sinatra></sinatra>', body\n+    end \n+    \n+    it 'sets the Content-Type response header without extname' do\n+      attachment_app('test')\n+      get '/attachment'\n+      assert_equal 'text/html;charset=utf-8', response['Content-Type']\n+      assert_equal '<sinatra></sinatra>', body   \n+    end\n+    \n+    it 'sets the Content-Type response header without extname' do\n+      mock_app do\n+        get '/attachment' do\n+          content_type :atom\n+          attachment 'test.xml'\n+          response.write(\"<sinatra></sinatra>\")\n+        end\n+      end\n+      get '/attachment'\n+      assert_equal 'application/atom+xml', response['Content-Type']\n+      assert_equal '<sinatra></sinatra>', body   \n+    end\n+    \n+  end\n+\n   describe 'send_file' do\n     setup do\n       @file = File.dirname(__FILE__) + '/file.txt'"
          }
        ],
        "commit": {
          "id": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc",
          "parents": [
            {
              "id": "9eb0dfe7dd0eaa48c5c55b6a1193f0c86f53f020"
            },
            {
              "id": "dd6fd9953b1a3568266e6a226c53093fb08a6817"
            }
          ],
          "tree": "a43281fdbc23304dcc7891321e4350e07c8cde41",
          "message": "Merge branch 'master' of github.com:sinatra/sinatra",
          "author": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "committer": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "authored_date": "2011-06-22T12:26:55-05:00",
          "committed_date": "2011-06-22T12:26:55-05:00"
        }
      }
    }
    
### Get commit payload

    GET /commit/payload?repo=sinatra&id=a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc
    
Response:

    {
      "result": true,
      "data": {
        "repository": "sinatra",
        "head": "master",
        "commits": {
          "id": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc",
          "message": "Merge branch 'master' of github.com:sinatra/sinatra",
          "timestamp": "2011-06-22T12:26:55-05:00",
          "author": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "added": [
    
          ],
          "removed": [
    
          ],
          "modified": [
            "lib/sinatra/base.rb",
            "test/helpers_test.rb"
          ]
        }
      }
    }


### Get commits count

    GET /commits_count?repo=sinatra
  
Response:

    {
      "result": true,
      "data": {
        "count": 1547
      }
    }

### Get commits stats by dates

    GET /commits_stats?repo=sinatra&days=5
    
Options:

  * days - Number of days from today (default: 30)
    
Response:

    {
      "result": true,
      "data": {
        "2011-06-20": 0,
        "2011-06-21": 0,
        "2011-06-22": 2,
        "2011-06-23": 0,
        "2011-06-24": 0,
        "2011-06-25": 0
      }
    }

## Get commits diff

    GET /compare?repo=sinatra&obj_from=ec1b83d566c888d9d53d54b262def820f00834cb&obj_to=e9de3248fb4e86a9cd6318c6a6e284c7db101df3
    
Response:

    {
      "result": true,
      "data": {
        "commits": [
          {
            "id": "e9de3248fb4e86a9cd6318c6a6e284c7db101df3",
            "parents": [
              {
                "id": "ec1b83d566c888d9d53d54b262def820f00834cb"
              }
            ],
            "tree": "85a051f3b4bf41fd439138f1938ddc27124f1e30",
            "message": "add failing test for attachment",
            "author": {
              "name": "nashby",
              "email": "younash@gmail.com",
              "gravatar": "608b32640d0fca097b40bc6a28cadc5f"
            },
            "committer": {
              "name": "nashby",
              "email": "younash@gmail.com",
              "gravatar": "608b32640d0fca097b40bc6a28cadc5f"
            },
            "authored_date": "2011-06-17T14:57:20-05:00",
            "committed_date": "2011-06-17T14:57:20-05:00"
          }
        ],
        "diff": [
          {
            "a_path": "test/helpers_test.rb",
            "b_path": "test/helpers_test.rb",
            "deleted_file": false,
            "new_file": false,
            "content": "--- a/test/helpers_test.rb\n+++ b/test/helpers_test.rb\n@@ -593,6 +593,12 @@ class HelpersTest < Test::Unit::TestCase\n       assert_equal '<sinatra></sinatra>', body\n     end \n     \n+    it 'sets the Content-Type response header without extname' do\n+      attachment_app('test')\n+      get '/attachment'\n+      assert_equal '<sinatra></sinatra>', body   \n+    end\n+    \n   end\n \n   describe 'send_file' do"
          }
        ]
      }
    }

### Get a tree

    GET /tree?repo=sinatra&path=lib/&history=true
    
Options:

  * path - Tree path (default: root)
  * history - Include last commit information for the tree items (default: false)
    
Response:

    {
      "result": true,
      "data": {
        "head": "master",
        "path": "lib/",
        "commit": {
          "id": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc",
          "parents": [
            {
              "id": "9eb0dfe7dd0eaa48c5c55b6a1193f0c86f53f020"
            },
            {
              "id": "dd6fd9953b1a3568266e6a226c53093fb08a6817"
            }
          ],
          "tree": "a43281fdbc23304dcc7891321e4350e07c8cde41",
          "message": "Merge branch 'master' of github.com:sinatra/sinatra",
          "author": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "committer": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "authored_date": "2011-06-22T12:26:55-05:00",
          "committed_date": "2011-06-22T12:26:55-05:00"
        },
        "tree": [
          {
            "id": "b05028060f4c1be860518a55c85404928298f3ee",
            "type": "tree",
            "name": "lib/sinatra",
            "mode": "040000",
            "filesize": null,
            "commit": {
              "id": "2b31a86de07c4ef80faf22bbb8f3aa21bdea8577",
              "parents": [
                {
                  "id": "e9de3248fb4e86a9cd6318c6a6e284c7db101df3"
                }
              ],
              "tree": "a6642f18a7cac601fbf1cb8e311a6fd3f8dcaa9b",
              "message": "fix failing test for attachment",
              "author": {
                "name": "nashby",
                "email": "younash@gmail.com",
                "gravatar": "608b32640d0fca097b40bc6a28cadc5f"
              },
              "committer": {
                "name": "nashby",
                "email": "younash@gmail.com",
                "gravatar": "608b32640d0fca097b40bc6a28cadc5f"
              },
              "authored_date": "2011-06-18T03:47:50-05:00",
              "committed_date": "2011-06-18T03:47:50-05:00"
            }
          },
          {
            "id": "71b122d1af6997f89ddb05ada1d1ea9821fa87fc",
            "type": "blob",
            "name": "lib/sinatra.rb",
            "mode": "100644",
            "filesize": 167,
            "commit": {
              "id": "3ef8eedef257b513f531dd48bfedcbc8df8a622b",
              "parents": [
                {
                  "id": "0067232e1f75c02b9ea51bba2ca5e5fb3b7ae070"
                }
              ],
              "tree": "d65d452219fab096c381afc6872b80c73daaa30d",
              "message": "Deprecate use_in_file_templates!\n\nUse enable :inline_templates instead",
              "author": {
                "name": "Simon Rozet",
                "email": "simon@rozet.name",
                "gravatar": "8cf17bf55c4d16cf52480619bb0b6c92"
              },
              "committer": {
                "name": "Simon Rozet",
                "email": "simon@rozet.name",
                "gravatar": "8cf17bf55c4d16cf52480619bb0b6c92"
              },
              "authored_date": "2009-12-18T19:07:01-06:00",
              "committed_date": "2009-12-22T21:40:43-06:00"
            }
          }
        ]
      }
    }

### Get a tree history

    GET /tree_history?repo=sinatra&path=lib/
    
Options:

  * path - Tree path (default: root)
    
Response:

    {
      "result": true,
      "data": {
        "b05028060f4c1be860518a55c85404928298f3ee": {
          "id": "2b31a86de07c4ef80faf22bbb8f3aa21bdea8577",
          "parents": [
            {
              "id": "e9de3248fb4e86a9cd6318c6a6e284c7db101df3"
            }
          ],
          "tree": "a6642f18a7cac601fbf1cb8e311a6fd3f8dcaa9b",
          "message": "fix failing test for attachment",
          "author": {
            "name": "nashby",
            "email": "younash@gmail.com",
            "gravatar": "608b32640d0fca097b40bc6a28cadc5f"
          },
          "committer": {
            "name": "nashby",
            "email": "younash@gmail.com",
            "gravatar": "608b32640d0fca097b40bc6a28cadc5f"
          },
          "authored_date": "2011-06-18T03:47:50-05:00",
          "committed_date": "2011-06-18T03:47:50-05:00"
        },
        "71b122d1af6997f89ddb05ada1d1ea9821fa87fc": {
          "id": "3ef8eedef257b513f531dd48bfedcbc8df8a622b",
          "parents": [
            {
              "id": "0067232e1f75c02b9ea51bba2ca5e5fb3b7ae070"
            }
          ],
          "tree": "d65d452219fab096c381afc6872b80c73daaa30d",
          "message": "Deprecate use_in_file_templates!\n\nUse enable :inline_templates instead",
          "author": {
            "name": "Simon Rozet",
            "email": "simon@rozet.name",
            "gravatar": "8cf17bf55c4d16cf52480619bb0b6c92"
          },
          "committer": {
            "name": "Simon Rozet",
            "email": "simon@rozet.name",
            "gravatar": "8cf17bf55c4d16cf52480619bb0b6c92"
          },
          "authored_date": "2009-12-18T19:07:01-06:00",
          "committed_date": "2009-12-22T21:40:43-06:00"
        }
      }
    }

### Get a blob

    GET /blob?repo=sinatra&path=lib/sinatra.rb
    
Options:

  * path - Blob path (required)
  * head - Use this branch to get blob
  
Response:

    {
      "result": true,
      "data": {
        "head": "master",
        "commit": {
          "id": "a6f6a147bfe3a9d7cd05f8e06212fc0ea8e23dcc",
          "parents": [
            {
              "id": "9eb0dfe7dd0eaa48c5c55b6a1193f0c86f53f020"
            },
            {
              "id": "dd6fd9953b1a3568266e6a226c53093fb08a6817"
            }
          ],
          "tree": "a43281fdbc23304dcc7891321e4350e07c8cde41",
          "message": "Merge branch 'master' of github.com:sinatra/sinatra",
          "author": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "committer": {
            "name": "Konstantin Haase",
            "email": "konstantin.mailinglists@googlemail.com",
            "gravatar": "5c2b452f6eea4a6d84c105ebd971d2a4"
          },
          "authored_date": "2011-06-22T12:26:55-05:00",
          "committed_date": "2011-06-22T12:26:55-05:00"
        },
        "path": "lib/sinatra.rb",
        "blob": {
          "id": "71b122d1af6997f89ddb05ada1d1ea9821fa87fc",
          "name": "sinatra.rb",
          "mime_type": "application/ruby",
          "mode": "100644",
          "filesize": 167,
          "binary": null,
          "data": "libdir = File.dirname(__FILE__)\n$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)\n\nrequire 'sinatra/base'\nrequire 'sinatra/main'\n\nenable :inline_templates\n"
        }
      }
    }
    
### Get a RAW blob data

This request does not return JSON, it returns the actual content of the blob instead.


    GET /raw?repo=sinatra&path=lib/sinatra.rb

Response:

    BLOB CONTENT

### Get a blob blame information

    GET /blame?repo=sinatra&path=lib/sinatra.rb
  
Response:

    {
      "result": true,
      "data": {
        "head": "master",
        "path": "lib/sinatra.rb",
        "blob": {
          "id": "71b122d1af6997f89ddb05ada1d1ea9821fa87fc",
          "name": "sinatra.rb",
          "mime_type": "application/ruby",
          "mode": "100644",
          "filesize": 167,
          "binary": null,
          "data": "libdir = File.dirname(__FILE__)\n$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)\n\nrequire 'sinatra/base'\nrequire 'sinatra/main'\n\nenable :inline_templates\n"
        },
        "blame": [
          {
            "commit": {
              "id": "0324732179f8b732abd1790dabce468b3894d756",
              "parents": [
                {
                  "id": "eec7d2141685b8a44fc202a58f384bfad6c3d435"
                }
              ],
              "tree": "a5018db2cd6baf6153798885943c97850483cdb8",
              "message": "Minor tweaks to use_in_file_templates! auto loading",
              "author": {
                "name": "Ryan Tomayko",
                "email": "rtomayko@gmail.com",
                "gravatar": "abfc88b96ae18c85ba7aac3bded2ec5e"
              },
              "committer": {
                "name": "Ryan Tomayko",
                "email": "rtomayko@gmail.com",
                "gravatar": "abfc88b96ae18c85ba7aac3bded2ec5e"
              },
              "authored_date": "2009-01-16T20:45:22-06:00",
              "committed_date": "2009-01-17T19:10:10-06:00"
            },
            "lines": [
              [
                "libdir = File.dirname(__FILE__)",
                "$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)",
                ""
              ]
            ]
          },
          {
            "commit": {
              "id": "a734cf38ac0e7ddee437c8d273de50f2a4053339",
              "parents": [
                {
                  "id": "d25e0208800e2fd69522e6b08e909c9c8d746b83"
                }
              ],
              "tree": "9e373aedfdc65188ee38f703c73decf8882ffec6",
              "message": "I knew I shoulda taken that left turn at Hoboken",
              "author": {
                "name": "Ryan Tomayko",
                "email": "rtomayko@gmail.com",
                "gravatar": "abfc88b96ae18c85ba7aac3bded2ec5e"
              },
              "committer": {
                "name": "Ryan Tomayko",
                "email": "rtomayko@gmail.com",
                "gravatar": "abfc88b96ae18c85ba7aac3bded2ec5e"
              },
              "authored_date": "2008-12-13T15:06:02-06:00",
              "committed_date": "2008-12-20T20:45:28-06:00"
            },
            "lines": [
              [
                "require 'sinatra/base'",
                "require 'sinatra/main'"
              ]
            ]
          },
          {
            "commit": {
              "id": "eec7d2141685b8a44fc202a58f384bfad6c3d435",
              "parents": [
                {
                  "id": "15863661c33f2ba9bc03a6df325e97c285943152"
                }
              ],
              "tree": "3760c14705d0b32d632cb735e7df6d96fb4d5eb6",
              "message": "In-file-templates are automaticly loaded for you.",
              "author": {
                "name": "Blake Mizerany",
                "email": "blake.mizerany@gmail.com",
                "gravatar": "1a250566b475961b9b36abf359950c76"
              },
              "committer": {
                "name": "Blake Mizerany",
                "email": "blake.mizerany@gmail.com",
                "gravatar": "1a250566b475961b9b36abf359950c76"
              },
              "authored_date": "2009-01-16T19:01:41-06:00",
              "committed_date": "2009-01-17T19:05:17-06:00"
            },
            "lines": [
              [
                ""
              ]
            ]
          },
          {
            "commit": {
              "id": "3ef8eedef257b513f531dd48bfedcbc8df8a622b",
              "parents": [
                {
                  "id": "0067232e1f75c02b9ea51bba2ca5e5fb3b7ae070"
                }
              ],
              "tree": "d65d452219fab096c381afc6872b80c73daaa30d",
              "message": "Deprecate use_in_file_templates!",
              "author": {
                "name": "Simon Rozet",
                "email": "simon@rozet.name",
                "gravatar": "8cf17bf55c4d16cf52480619bb0b6c92"
              },
              "committer": {
                "name": "Simon Rozet",
                "email": "simon@rozet.name",
                "gravatar": "8cf17bf55c4d16cf52480619bb0b6c92"
              },
              "authored_date": "2009-12-18T19:07:01-06:00",
              "committed_date": "2009-12-22T21:40:43-06:00"
            },
            "lines": [
              [
                "enable :inline_templates"
              ]
            ]
          }
        ]
      }
    }


## License

Copyright &copy; 2011 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.