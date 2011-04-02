use Bio::Role::Identify;
class Bio::Annotation::DBLink does Bio::Role::Identify {
# use base qw(Bio::Root::Root Bio::AnnotationI Bio::IdentifiableI);

# =head2 new

#  Title   : new
#  Usage   : $dblink = Bio::Annotation::DBLink.new(-database =>"GenBank",
#                                                   -primary_id => "M123456");
#  Function: Creates a new instance of this class.
#  Example :
#  Returns : A new instance of Bio::Annotation::DBLink.
#  Args    : Named parameters. At present, the following parameters are
#            recognized.

#              -database    the name of the database referenced by the xref
#              -primary_id  the primary (main) id of the referenced entry
#                           (usually this will be an accession number)
#              -optional_id a secondary ID under which the referenced entry
#                           is known in the same database
#              -comment     comment text for the dbxref
#              -tagname     the name of the tag under which to add this
#                           instance to an annotation bundle (usually 'dblink')
#              -namespace   synonymous with -database (also overrides)
#              -version     version of the referenced entry
#              -authority   attribute of the Bio::IdentifiableI interface
#              -url         attribute of the Bio::IdentifiableI interface

# =cut

# method new {
#   my($class,@args) = @_;

#   my $self = $class->SUPER::new(@args);

#   my ($database,$primary_id,$optional_id,$comment,$tag,$ns,$auth,$v,$url) =
#       $self->_rearrange([qw(DATABASE
# 			    PRIMARY_ID
# 			    OPTIONAL_ID
# 			    COMMENT
# 			    TAGNAME
# 			    NAMESPACE
# 			    AUTHORITY
# 			    VERSION
# 			    URL
# 			    )], @args);
  
#   $database    && $self->database($database);
#   $primary_id  && $self->primary_id($primary_id);
#   $optional_id && $self->optional_id($optional_id);
#   $comment     && $self->comment($comment);
#   $tag         && $self->tagname($tag);
#   # Bio::IdentifiableI parameters:
#   $ns          && $self->namespace($ns); # this will override $database
#   $auth        && $self->authority($auth);
#   defined($v)  && $self->version($v);
#   defined($url)  && $self->url($url);

#   return $self;
# }

# =head1 AnnotationI implementing functions

# =cut


# =head2 as_text

#  Title   : as_text
#  Usage   :
#  Function:
#  Example :
#  Returns : 
#  Args    :


# =cut

method as_text(){
   return "Direct database link to " ~ self.primary_id
       ~ (self.version ?? "." ~ self.version !! "")
       ~ (self.optional_id ?? " (" ~ self.optional_id ~ ")" !! "")
       ~ " in database " ~ self.database;
}

# =head2 display_text

#  Title   : display_text
#  Usage   : my $str = $ann.display_text();
#  Function: returns a string. Unlike as_text(), this method returns a string
#            formatted as would be expected for te specific implementation.

#            One can pass a callback as an argument which allows custom text
#            generation; the callback is passed the current instance and any text
#            returned
#  Example :
#  Returns : a string
#  Args    : [optional] callback

# =cut

my $DEFAULT_CB = sub ($self) { (($self.database ?? $self.database ~ ':' !! '' ) ~
                           ($self.primary_id ?? $self.primary_id !! '') ~
                           ($self.version ?? '.' ~ $self.version !! '')) || '' };

method display_text($cb? is copy) {
    $cb ||= $DEFAULT_CB;
#     $self->throw("Callback must be a code reference") if ref $cb ne 'CODE';
    return $cb.(self);
}


# =head2 hash_tree

#  Title   : hash_tree
#  Usage   :
#  Function:
#  Example :
#  Returns : 
#  Args    :


# =cut

# method hash_tree{
#    my ($self) = @_;
   
#    my $h = {};
#    $h.{'database'}   = $self.database;
#    $h.{'primary_id'} = $self.primary_id;
#    if( defined $self.optional_id ) {
#        $h.{'optional_id'} = $self.optional_id;
#    }
#    if( defined $self.comment ) {
#        # we know that comments have hash_tree methods
#        $h.{'comment'} = $self.comment;
#    }

#    return $h;
# }

# =head2 tagname

#  Title   : tagname
#  Usage   : $obj.tagname($newval)
#  Function: Get/set the tagname for this annotation value.

#            Setting this is optional. If set, it obviates the need to
#            provide a tag to Bio::AnnotationCollectionI when adding
#            this object. When obtaining an AnnotationI object from the
#            collection, the collection will set the value to the tag
#            under which it was stored unless the object has a tag
#            stored already.

#  Example : 
#  Returns : value of tagname (a scalar)
#  Args    : new value (a scalar, optional)


# =cut

has $!tagname is rw;
method tagname($value?){
    return $!tagname = $value if defined $value;
    return $!tagname;
}

# =head1 Specific accessors for DBLinks

# =cut

# =head2 database

#  Title   : database
#  Usage   : $self.database($newval)
#  Function: set/get on the database string. Databases are just
#            a string here which can then be interpreted elsewhere
#  Example : 
#  Returns : value of database
#  Args    : newvalue (optional)

# =cut

has $!database is rw;

multi method database($value?){
     $!database = $value if defined $value;
     return $!database;
}


# =head2 optional_id

#  Title   : optional_id
#  Usage   : $self.optional_id($newval)
#  Function: get/set for the optional_id (a string)

#            optional id is a slot for people to use as they wish. The
#            main issue is that some databases do not have a clean
#            single string identifier scheme. It is hoped that the
#            primary_id can behave like a reasonably sane "single string
#            identifier" of objects, and people can use/abuse optional
#            ids to their heart's content to provide precise mappings.

#  Example : 
#  Returns : value of optional_id
#  Args    : newvalue (optional)

# =cut

has $!optional_id is rw;

method optional_id($value?){
    $!optional_id = $value if defined $value;
    return $!optional_id;
}

# =head2 comment

#  Title   : comment
#  Usage   : $self.comment($newval)
#  Function: get/set of comments (comment object)
#            Sets or gets comments of this dblink, which is sometimes relevant
#  Example : 
#  Returns : value of comment (Bio::Annotation::Comment)
#  Args    : newvalue (optional)

# =cut

# method comment{
#     my $self = shift;

#     return $self.{'comment'} = shift if @_;
#     return $self.{'comment'};
# }

# =head1 Methods for Bio::IdentifiableI compliance

# =head2 object_id

#  Title   : object_id
#  Usage   : $string    = $obj.object_id()
#  Function: a string which represents the stable primary identifier
#            in this namespace of this object. For DNA sequences this
#            is its accession_number, similarly for protein sequences

#            This is aliased to primary_id().
#  Returns : A scalar


# =cut

# method object_id {
#     return shift.primary_id(@_);
# }


# =head2 url

#  Title   : url
#  Usage   : $url    = $obj.url()
#  Function: URL which is associated with this DB link
#  Returns : string, full URL descriptor

# =cut

# method url {
#     my $self = shift;
#     return $self.{'url'} = shift if @_;
#     return $self.{'url'};
# }

# =head2 namespace

#  Title   : namespace
#  Usage   : $string    = $obj.namespace()
#  Function: A string representing the name space this identifier
#            is valid in, often the database name or the name
#            describing the collection 

#            For DBLink this is the same as database().
#  Returns : A scalar


# =cut

# method namespace{
#     return shift.database(@_);
# }

}

# $Id: DBLink.pm 15635 2009-04-14 19:11:13Z cjfields $
#
# BioPerl module for Bio::Annotation::DBLink
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

# =head1 NAME

# Bio::Annotation::DBLink - untyped links between databases

# =head1 SYNOPSIS

#    $link1 = Bio::Annotation::DBLink.new(-database => 'TSC',
#                                         -primary_id => 'TSC0000030'
# 					);

#    #or 

#    $link2 = Bio::Annotation::DBLink.new();
#    $link2.database('dbSNP');
#    $link2.primary_id('2367');

#    # DBLink is-a Bio::AnnotationI object, can be added to annotation
#    # collections, e.g. the one on features or seqs
#    $feat.annotation.add_Annotation('dblink', $link2);


# =head1 DESCRIPTION

# Provides an object which represents a link from one object to something
# in another database without prescribing what is in the other database.

# Aside from L<Bio::AnnotationI>, this class also implements
# L<Bio::IdentifiableI>.

# =head1 AUTHOR - Ewan Birney

# Ewan Birney - birney@ebi.ac.uk

# =head1 APPENDIX

# The rest of the documentation details each of the object
# methods. Internal methods are usually preceded with a _

# =cut

