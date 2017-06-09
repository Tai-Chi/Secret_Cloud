require 'sinatra'

class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

# Class for route /create/file
class FileSystemSyncAPI < Sinatra::Base

  # remove leading zero
  def _rlz(str)
    str.sub!(/^0+/, "")
    str = "0" if str == ""
    str
  end

  post '/create/file/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      path, portion, size, time = JsonParser.call(request, 'path', 'portion', 'size', 'time')
      if path==nil || portion==nil || size==nil || time==nil
        logger.info "Any parameter cannot be null."
        status 403
      else
        # Type checking
        path = path.to_s
        portion = Integer(portion)
        # gfid = gfid.to_s
        size = Integer(size)
        time = time.to_s.split(/[ ,:]/)
        time = DateTime.new(Integer(_rlz(time[0])),Integer(_rlz(time[1])),
                            Integer(_rlz(time[2])),Integer(_rlz(time[3])),
                            Integer(_rlz(time[4])),Integer(_rlz(time[5]))
        )

        # Body
        uid = account.id
        pathUnits, fName = SplitPath.call(path, true)
        dir, state = self.create_folder(uid, pathUnits)
        if state == :blocked
          logger.info "There may be some files blocking our route..."
          status 403
        elsif dir == nil
          logger.info "The path is not valid."
          status 403
        elsif (file=dir.find_file(fName, portion)) == nil
          # Find available google drive for this file
          gaccount = AllocateDriveSpace.call(account, size)
          halt 403, 'There is no available drive!!' if gaccount == nil
          # For database
          file = CreateFileinfo.call(name: fName, parent_id: dir.id, account_id: uid, portion: portion, gaccount_id: gaccount[:id], size: size, time: time)
          # For our in-memory tree
          dir.add_file(file)
          # Return fileinfo id and assigned gaccount
          body file.id.to_s + ' ' + gaccount.name
          # Here we may also verify that all portions before portion(Num)
          # must exist as well. However, due to the difficulty, we have
          # not implemented this feature yet.
          logger.info "FILE CREATED SUCCESSFULLY"
          status 200
        else
          if file[:time].to_datetime < time
            logger.info 'The file has been outdated.'
            halt 403, 'OUTDATED'
          else
            logger.info 'The file has already existed.'
            halt 403, 'EXISTED'
          end
        end
      end
    rescue => e
      logger.info "FAILED to create the new file: #{e.inspect}"
      status 400
    end
  end
end