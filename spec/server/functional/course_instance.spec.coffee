async = require 'async'
config = require '../../../server_config'
require '../common'
stripe = require('stripe')(config.stripe.secretKey)
init = require '../init'

describe 'POST /db/course_instance', ->

  beforeEach (done) -> clearModels([CourseInstance, Course, User, Classroom], done)
  beforeEach (done) -> loginJoe (@joe) => done()
  beforeEach init.course()
  beforeEach init.classroom()

  it 'creates a CourseInstance', (done) ->
    test = @
    url = getURL('/db/course_instance')
    data = {
      name: 'Some Name'
      courseID: test.course.id
      classroomID: test.classroom.id
    }
    request.post {uri: url, json: data}, (err, res, body) ->
      expect(res.statusCode).toBe(200)
      expect(body.classroomID).toBeDefined()
      done()

  it 'returns 404 if the Course does not exist', (done) ->
    test = @
    url = getURL('/db/course_instance')
    data = {
      name: 'Some Name'
      courseID: '123456789012345678901234'
      classroomID: test.classroom.id
    }
    request.post {uri: url, json: data}, (err, res, body) ->
      expect(res.statusCode).toBe(404)
      done()

<<<<<<< HEAD
  describe 'Single courses', ->
    it 'Create for free course 1 seat', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 1, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              done()

    it 'Create for free course no seats', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            name = createName 'course instance '
            requestBody =
              courseID: course.get('_id')
              name: createName('course instance ')
            request.post {uri: courseInstanceCreateURL, json: requestBody }, (err, res) ->
              expect(err).toBeNull()
              expect(res.statusCode).toBe(422)
              done()

    it 'Create for free course no token', (done) ->
      loginNewUser (user1) ->
        createCourse 0, (err, course) ->
          expect(err).toBeNull()
          return done(err) if err
          createCourseInstances user1, course.get('_id'), 2, null, (err, courseInstances) ->
            expect(err).toBeNull()
            return done(err) if err
            expect(courseInstances.length).toEqual(1)
            done()

    it 'Create for paid course 1 seat', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 7000, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 1, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                expect(err).toBeNull()
                return done(err) if err
                expect(prepaid.get('maxRedeemers')).toEqual(1)
                expect(prepaid.get('properties')?.courseIDs).toEqual([course.get('_id')])
                done()

    it 'Create for paid course 50 seats', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 7000, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 50, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                expect(err).toBeNull()
                return done(err) if err
                expect(prepaid.get('maxRedeemers')).toEqual(50)
                expect(prepaid.get('properties')?.courseIDs).toEqual([course.get('_id')])
                done()

    it 'Create for paid course no token', (done) ->
      loginNewUser (user1) ->
        createCourse 7000, (err, course) ->
          expect(err).toBeNull()
          return done(err) if err
          name = createName 'course instance '
          requestBody =
            courseID: course.get('_id')
            name: createName('course instance ')
            seats: 1
          request.post {uri: courseInstanceCreateURL, json: requestBody }, (err, res) ->
            expect(err).toBeNull()
            expect(res.statusCode).toBe(422)
            done()

    it 'Create for paid course -1 seats', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 7000, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            name = createName 'course instance '
            requestBody =
              courseID: course.get('_id')
              name: createName('course instance ')
              seats: -1
            request.post {uri: courseInstanceCreateURL, json: requestBody }, (err, res) ->
              expect(err).toBeNull()
              expect(res.statusCode).toBe(422)
              done()

  describe 'All Courses', ->
    it 'Create for 50 seats', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 7000, (err, course1) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourse 7000, (err, course2) ->
              expect(err).toBeNull()
              return done(err) if err
              createCourseInstances user1, null, 50, token.id, (err, courseInstances) ->
                expect(err).toBeNull()
                return done(err) if err
                Course.find {}, (err, courses) ->
                  expect(err).toBeNull()
                  return done(err) if err
                  expect(courseInstances.length).toEqual(courses.length)
                  Prepaid.find creator: user1.get('_id'), (err, prepaids) ->
                    expect(err).toBeNull()
                    return done(err) if err
                    expect(prepaids.length).toEqual(1)
                    return done('no prepaids found') unless prepaids?.length > 0
                    prepaid = prepaids[0]
                    expect(prepaid.get('maxRedeemers')).toEqual(50)
                    expect(prepaid.get('properties')?.courseIDs?.length).toEqual(courses.length)
                    done()

  describe 'Invite to course', ->
    it 'takes a list of emails and sends invites', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 1, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              inviteStudentsURL = getURL("/db/course_instance/#{courseInstances[0]._id}/invite_students")
              requestBody = {
                emails: ['test@test.com']
              }
              request.post { uri: inviteStudentsURL, json: requestBody }, (err, res) ->
                expect(err).toBeNull()
                expect(res.statusCode).toBe(200)
                done()

  describe 'Redeem prepaid code', ->

    it 'Redeem prepaid code for an instance of max 2', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 2, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                expect(err).toBeNull()
                return done(err) if err
                loginNewUser (user2) ->
                  request.post {uri: courseInstanceRedeemURL, json: {prepaidCode: prepaid.get('code')} }, (err, res) ->
                    expect(err).toBeNull()
                    expect(res.statusCode).toBe(200)

                    # Check prepaid
                    Prepaid.findById prepaid.id, (err, prepaid) ->
                      expect(err).toBeNull()
                      return done(err) if err
                      expect(prepaid.get('redeemers')?.length).toEqual(1)
                      expect(prepaid.get('redeemers')[0].date).toBeLessThan(new Date())
                      expect(prepaid.get('redeemers')[0].userID).toEqual(user2.get('_id'))

                      # Check course instance
                      CourseInstance.findById courseInstances[0].id, (err, courseInstance) ->
                        expect(err).toBeNull()
                        return done(err) if err
                        members = courseInstance.get('members')
                        expect(members?.length).toEqual(2)
                        # TODO: must be a better way to check membership
                        usersFound = 0
                        for memberID in members
                          usersFound++ if memberID.equals(user1.get('_id'))
                          usersFound++ if memberID.equals(user2.get('_id'))
                        expect(usersFound).toEqual(2)
                        done()

    it 'Redeem full prepaid code for on instance of max 1', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 1, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                expect(err).toBeNull()
                return done(err) if err
                loginNewUser (user2) ->
                  request.post {uri: courseInstanceRedeemURL, json: {prepaidCode: prepaid.get('code')} }, (err, res) ->
                    expect(err).toBeNull()
                    expect(res.statusCode).toBe(200)
                    loginNewUser (user3) ->
                      request.post {uri: courseInstanceRedeemURL, json: {prepaidCode: prepaid.get('code')} }, (err, res) ->
                        expect(err).toBeNull()
                        expect(res.statusCode).toBe(403)
                        done()

    xit 'Redeem 50 count course prepaid codes 51 times, in parallel', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        seatCount = 50
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), seatCount, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                expect(err).toBeNull()
                return done(err) if err

                forbiddenResults = 0
                makeRedeemCall = ->
                  (callback) ->
                    loginNewUser (user2) ->
                      request.post {uri: courseInstanceRedeemURL, json: {prepaidCode: prepaid.get('code')} }, (err, res) ->
                        expect(err).toBeNull()
                        if res.statusCode is 403
                          forbiddenResults++
                        else
                          expect(res.statusCode).toBe(200)
                        callback err
                tasks = (makeRedeemCall() for i in [1..seatCount+1])
                async.parallel tasks, (err, results) ->
                  expect(err?).toEqual(false)
                  expect(forbiddenResults).toEqual(1)
                  Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                    expect(err).toBeNull()
                    return done(err) if err
                    expect(prepaid.get('redeemers')?.length).toEqual(prepaid.get('maxRedeemers'))
                    done()

    it 'Redeem prepaid code twice', (done) ->
      stripe.tokens.create {
        card: { number: '4242424242424242', exp_month: 12, exp_year: 2020, cvc: '123' }
      }, (err, token) ->
        loginNewUser (user1) ->
          createCourse 0, (err, course) ->
            expect(err).toBeNull()
            return done(err) if err
            createCourseInstances user1, course.get('_id'), 2, token.id, (err, courseInstances) ->
              expect(err).toBeNull()
              return done(err) if err
              expect(courseInstances.length).toEqual(1)
              Prepaid.findById courseInstances[0].get('prepaidID'), (err, prepaid) ->
                expect(err).toBeNull()
                return done(err) if err
                loginNewUser (user2) ->
                  # Redeem once
                  request.post {uri: courseInstanceRedeemURL, json: {prepaidCode: prepaid.get('code')} }, (err, res) ->
                    expect(err).toBeNull()
                    expect(res.statusCode).toBe(200)
                    # Redeem twice
                    request.post {uri: courseInstanceRedeemURL, json: {prepaidCode: prepaid.get('code')} }, (err, res) ->
                      expect(err).toBeNull()
                      expect(res.statusCode).toBe(200)
                      done()
=======
  it 'returns 404 if the Classroom does not exist', (done) ->
    test = @
    url = getURL('/db/course_instance')
    data = {
      name: 'Some Name'
      courseID: test.course.id
      classroomID: '123456789012345678901234'
    }
    request.post {uri: url, json: data}, (err, res, body) ->
      expect(res.statusCode).toBe(404)
      done()

  it 'return 403 if the logged in user does not own the Classroom', (done) ->
    test = @
    loginSam ->
      url = getURL('/db/course_instance')
      data = {
        name: 'Some Name'
        courseID: test.course.id
        classroomID: test.classroom.id
      }
      request.post {uri: url, json: data}, (err, res, body) ->
        expect(res.statusCode).toBe(403)
        done()


describe 'POST /db/course_instance/:id/members', ->

  beforeEach (done) -> clearModels([CourseInstance, Course, User, Classroom, Prepaid], done)
  beforeEach (done) -> loginJoe (@joe) => done()
  beforeEach init.course({free: true})
  beforeEach init.classroom()
  beforeEach init.courseInstance()
  beforeEach init.user()
  beforeEach init.prepaid()

  it 'adds a member to the given CourseInstance', (done) ->
    async.eachSeries([

      addTestUserToClassroom,
      (test, cb) ->
        url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
        request.post {uri: url, json: {userID: test.user.id}}, (err, res, body) ->
          expect(res.statusCode).toBe(200)
          expect(body.members.length).toBe(1)
          expect(body.members[0]).toBe(test.user.id)
          cb()

    ], makeTestIterator(@), done)

  it 'adds the CourseInstance id to the user', (done) ->
    async.eachSeries([

      addTestUserToClassroom,
      (test, cb) ->
        url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
        request.post {uri: url, json: {userID: test.user.id}}, (err, res, body) ->
          User.findById(test.user.id).exec (err, user) ->
            expect(_.size(user.get('courseInstances'))).toBe(1)
            cb()
    ], makeTestIterator(@), done)

  it 'return 403 if the member is not in the classroom', (done) ->
    async.eachSeries([

      (test, cb) ->
        url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
        request.post {uri: url, json: {userID: test.user.id}}, (err, res) ->
          expect(res.statusCode).toBe(403)
          cb()

    ], makeTestIterator(@), done)


  it 'returns 403 if the user does not own the course instance and is not adding self', (done) ->
    async.eachSeries([

      addTestUserToClassroom,
      (test, cb) ->
        loginSam ->
          url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
          request.post {uri: url, json: {userID: test.user.id}}, (err, res, body) ->
            expect(res.statusCode).toBe(403)
            cb()

    ], makeTestIterator(@), done)

  it 'returns 200 if the user is a member of the classroom and is adding self', ->

  it 'return 402 if the course is not free and the user is not in a prepaid', (done) ->
    async.eachSeries([

      addTestUserToClassroom,
      makeTestCourseNotFree,
      (test, cb) ->
        url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
        request.post {uri: url, json: {userID: test.user.id}}, (err, res) ->
          expect(res.statusCode).toBe(402)
          cb()
          
    ], makeTestIterator(@), done)
          
    
  it 'works if the course is not free and the user is in a prepaid', (done) ->
    async.eachSeries([
    
      addTestUserToClassroom,
      makeTestCourseNotFree,
      addTestUserToPrepaid,
      (test, cb) ->
        url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
        request.post {uri: url, json: {userID: test.user.id}}, (err, res) ->
          expect(res.statusCode).toBe(200)
          cb()
          
    ], makeTestIterator(@), done)
    
    
  makeTestCourseNotFree = (test, cb) ->
    test.course.set('free', false)
    test.course.save cb
        
  addTestUserToClassroom = (test, cb) ->
    test.classroom.set('members', [test.user.get('_id')])
    test.classroom.save cb

  addTestUserToPrepaid = (test, cb) ->
    test.prepaid.set('redeemers', [{userID: test.user.get('_id')}])
    test.prepaid.save cb


describe 'DELETE /db/course_instance/:id/members', ->

  beforeEach (done) -> clearModels([CourseInstance, Course, User, Classroom, Prepaid], done)
  beforeEach (done) -> loginJoe (@joe) => done()
  beforeEach init.course({free: true})
  beforeEach init.classroom()
  beforeEach init.courseInstance()
  beforeEach init.user()
  beforeEach init.prepaid()

  it 'removes a member to the given CourseInstance', (done) ->
    async.eachSeries([

      addTestUserToClassroom,
      addTestUserToCourseInstance,
      (test, cb) ->
        url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
        request.del {uri: url, json: {userID: test.user.id}}, (err, res, body) ->
          expect(res.statusCode).toBe(200)
          expect(body.members.length).toBe(0)
          cb()

    ], makeTestIterator(@), done)
    
  it 'removes the CourseInstance from the User.courseInstances', (done) ->
    async.eachSeries([

      addTestUserToClassroom,
      addTestUserToCourseInstance,
      (test, cb) ->
        User.findById(test.user.id).exec (err, user) ->
          expect(_.size(user.get('courseInstances'))).toBe(1)
          cb()
      removeTestUserFromCourseInstance,
      (test, cb) ->
        User.findById(test.user.id).exec (err, user) ->
          expect(_.size(user.get('courseInstances'))).toBe(0)
          cb()

    ], makeTestIterator(@), done)

  addTestUserToClassroom = (test, cb) ->
    test.classroom.set('members', [test.user.get('_id')])
    test.classroom.save cb

  addTestUserToCourseInstance = (test, cb) ->
    url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
    request.post {uri: url, json: {userID: test.user.id}}, (err, res, body) ->
      expect(res.statusCode).toBe(200)
      expect(body.members.length).toBe(1)
      expect(body.members[0]).toBe(test.user.id)
      cb()
      
  removeTestUserFromCourseInstance = (test, cb) ->
    url = getURL("/db/course_instance/#{test.courseInstance.id}/members")
    request.del {uri: url, json: {userID: test.user.id}}, (err, res, body) ->
      expect(res.statusCode).toBe(200)
      expect(body.members.length).toBe(0)
      cb()
  

makeTestIterator = (testObject) -> (func, callback) -> func(testObject, callback)
  
>>>>>>> refs/remotes/codecombat/master
