require File.dirname(__FILE__) + '/../spec_helper'

describe VCardigan::Property do

  describe '#init' do
    let(:vcard) { VCardigan.create }

    context 'without a group' do
      let(:name) { :email }
      let(:value) { 'joe@strummer.com' }
      let(:params) { { :type => 'uri' } }
      let(:prop) { VCardigan::Property.create(vcard, name, value, params) }

      it 'should set the name' do
        prop.name.should == name.to_s.downcase
      end

      it 'should set the value' do
        prop.values.first.should == value
      end
    end
  end

  describe '#values' do
    let(:vcard) { VCardigan.create }
    let(:name) { :email }
    let(:value) { 'joe@strummer.com' }
    let(:prop) { VCardigan::Property.create(vcard, name, value) }

    it 'should return the values array' do
      prop.values.should == prop.instance_variable_get(:@values)
    end
  end

  describe '#value' do
    let(:vcard) { VCardigan.create }
    let(:name) { :n }
    let(:value1) { 'Strummer' }
    let(:value2) { 'Joe' }
    let(:prop) { VCardigan::Property.create(vcard, name, value1, value2) }

    context 'without an index' do
      it 'should return the first item from the values array' do
        prop.value.should == prop.instance_variable_get(:@values).first
      end
    end

    context 'with an index' do
      it 'should return the item corresponding to the index' do
        prop.value(1).should == prop.instance_variable_get(:@values)[1]
      end
    end
  end

  describe '#params' do
    let(:vcard) { VCardigan.create }
    let(:name) { :email }
    let(:value) { 'joe@strummer.com' }
    let(:params) { { :type => 'uri' } }
    let(:prop) { VCardigan::Property.create(vcard, name, value, params) }

    it 'should return the params array' do
      prop.params.should == prop.instance_variable_get(:@params)
    end
  end

  describe '#param' do
    let(:vcard) { VCardigan.create }
    let(:name) { :email }
    let(:value) { 'joe@strummer.com' }
    let(:params) { { :type => 'uri' } }
    let(:prop) { VCardigan::Property.create(vcard, name, value, params) }

    context 'with a param that exists' do
      it 'should return the param' do
        prop.param(:type).should == params[:type]
      end
    end

    context 'with a param that does not exist' do
      it 'should return nil' do
        prop.param(:random).should == nil
      end
    end
  end

  describe '#to_s' do
    let(:vcard) { VCardigan.create }
    let(:group) { :item1 }

    context "fields with a single value" do
      let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }
      let(:name) { :email }
      let(:value) { 'joe@strummer.com' }
      let(:params) { { :type => 'uri' } }

      it 'should return the property vCard formatted' do
        prop.to_s.should == "#{group}.#{name.upcase};TYPE=#{params[:type]}:#{value}"
      end

      context 'with properties that return long strings' do
        let(:value) { 'qwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwert' }
        let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

        it 'should line fold at 75 chars' do
          prop.to_s.split("\n").each do |line|
            line.length.should <= 75
          end
        end

        context 'when chars option is set to 50' do
          let(:chars) { 50 }
          let(:vcard) { VCardigan.create(:chars => chars) }
          let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

          it 'should line fold at 50 chars' do
            prop.to_s.split("\n").each do |line|
              line.length.should <= 50
            end
          end
        end

        context 'when chars option is set to 0' do
          let(:chars) { 0 }
          let(:vcard) { VCardigan.create(:chars => chars) }
          let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

          it 'should not line fold' do
            ret = "#{group}.#{name.upcase};TYPE=#{params[:type]}:#{value}"
            prop.to_s.split("\n").length.should == 1
            prop.to_s.length.should == ret.length
          end
        end
      end
    end
  end

  describe 'escaping characters' do
    let(:vcard) { VCardigan.create }

    context "fields with single values" do
      let(:group) { :item1 }
      let(:field) { :note }

      context "line breaks" do
        it "should escape newlines properly" do
          value = "Line1\nLine2"
          exp_value = "Line1\\\\nLine2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end

        it "should not escape already escaped newlines" do
          value = "Line1\\nLine2"
          exp_value = "Line1\\\\nLine2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end

        it "should ignore windows newlines" do
          value = "Line1\r\nLine2"
          exp_value = "Line1\\\\nLine2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end
      end

      context "semicolons" do
        it "should escape semicolons" do
          value = "Line1;Line2"
          exp_value = "Line1\\;Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end

        it "should not escape already escaped semicolons" do
          value = "Line1\;Line2"
          exp_value = "Line1\\;Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end
      end

      context "commas" do
        it "should escape commas" do
          value = "Line1,Line2"
          exp_value = "Line1\\,Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end

        it "should not escape already escaped commas" do
          value = "Line1\\,Line2"
          exp_value = "Line1\\,Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end
      end

      context "semicolons" do
        it "should escape semicolons" do
          value = "Line1;Line2"
          exp_value = "Line1\\;Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end

        it "should not escape already escaped semicolons" do
          value = "Line1\\;Line2"
          exp_value = "Line1\\;Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end
      end

      context "backslashes" do
        it "should escape backslashes" do
          value = "Line1\\Line2"
          exp_value = "Line1\\\\Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end

        it "should not escape already escaped backslashes" do
          value = "Line1\\\\Line2"
          exp_value = "Line1\\\\Line2"

          vcard.send(field, value)

          get_value(vcard, field).should == exp_value
        end
      end
    end

    context "fields with multiple values" do
      let(:group) { :item1 }

      context "escaping characters" do
        let(:field) { :adr }
        let(:value) { ['', '', "Street\nApt 1", 'City', 'State', 'Zip', 'Country'] }
        let(:exp_value) { ";;Street\\nApt 1;City;State;Zip;Country" }

        it 'should escape characters properly' do
          vcard.send(field, *value)

          vcard.send(field).first.to_s.split(":", 2).last.should == exp_value
        end
      end
    end
  end

  describe '#parse' do
    let(:vcard) { VCardigan.create }
    let(:name) { :email }
    let(:group) { :item1 }
    let(:value) { 'joe@strummer.com' }
    let(:params) { { :type => 'uri' } }
    let(:string) { "#{group}.#{name.upcase};TYPE=#{params[:type]}:#{value}" }
    let(:prop) { VCardigan::Property.parse(vcard, string) }

    it 'should set the group' do
      prop.group.should == group.to_s.downcase
    end

    it 'should set the name' do
      prop.name.should == name.to_s.downcase
    end

    it 'should set the values' do
      prop.values.should == [value]
    end
  end

  describe 'encode and decode' do

    context '#decode_text' do
      it 'should decode' do
        VCardigan::Property.decode_text('aa,\\n\\n,\\\\\,\\\\a\;\;b').equal?("aa,\n\n,\\,\\a;;b")
      end
    end

    it 'should encode and decode text' do
      enc_in = "+\\\\+\\n+\\N+\\,+\\;+\\a+\\b+\\c+"
      dec = VCardigan::Property.decode_text(enc_in)
      #puts("<#{enc_in}> => <#{dec}>")
      dec.equal?("+\\+\n+\n+,+;+a+b+c+")
      enc_out = VCardigan::Property.encode_text(dec)
      should_be = "+\\\\+\\n+\\n+\\,+\\;+a+b+c+"
      # Note a, b, and c are allowed to be escaped, but shouldn't be and
      # aren't in output
      #puts("<#{dec}> => <#{enc_out}>")
      enc_out.equal?(should_be)
    end

  end

  def get_value(vcard, field)
    vcard.send(field).first.to_s.split(":", 2).last
  end

end
